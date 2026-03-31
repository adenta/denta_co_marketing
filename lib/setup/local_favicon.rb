# frozen_string_literal: true

require "digest"
require "fileutils"
require "zlib"

module Setup
  module LocalFavicon
    module_function

    def generate(root:, svg_path:, png_path:)
      color = color_for_root(root)

      FileUtils.mkdir_p(File.dirname(svg_path))
      File.write(svg_path, svg_markup(color))
      File.binwrite(png_path, render_png(color))

      color
    end

    def color_for_root(root)
      hue, saturation, lightness = hsl_for_root(root)
      rgb_to_hex(hsl_to_rgb(hue / 360.0, saturation, lightness))
    end

    def hsl_for_root(root)
      digest = Digest::SHA512.digest(File.expand_path(root))

      [
        digest.unpack1("n") * 360.0 / 65_536,
        scale_byte(digest.getbyte(2), min: 0.58, max: 0.84),
        scale_byte(digest.getbyte(3), min: 0.45, max: 0.62)
      ]
    end

    def scale_byte(byte, min:, max:)
      min + ((byte / 255.0) * (max - min))
    end
    private_class_method :scale_byte

    def svg_markup(color)
      <<~SVG
        <svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
          <circle cx="256" cy="256" r="256" fill="#{color}"/>
        </svg>
      SVG
    end
    private_class_method :svg_markup

    def hue_to_rgb(p, q, t)
      t += 1 if t < 0
      t -= 1 if t > 1

      channel =
        if t < (1.0 / 6)
          p + ((q - p) * 6 * t)
        elsif t < 0.5
          q
        elsif t < (2.0 / 3)
          p + ((q - p) * ((2.0 / 3) - t) * 6)
        else
          p
        end

      (channel * 255).round
    end
    private_class_method :hue_to_rgb

    def hsl_to_rgb(hue, saturation, lightness)
      if saturation.zero?
        channel = (lightness * 255).round
        return [ channel, channel, channel ]
      end

      q = lightness < 0.5 ? lightness * (1 + saturation) : lightness + saturation - (lightness * saturation)
      p = (2 * lightness) - q

      [
        hue_to_rgb(p, q, hue + (1.0 / 3)),
        hue_to_rgb(p, q, hue),
        hue_to_rgb(p, q, hue - (1.0 / 3))
      ]
    end
    private_class_method :hsl_to_rgb

    def rgb_to_hex(rgb)
      format("#%02x%02x%02x", *rgb)
    end
    private_class_method :rgb_to_hex

    def png_chunk(type, data)
      [ data.bytesize ].pack("N") + type + data + [ Zlib.crc32(type + data) ].pack("N")
    end
    private_class_method :png_chunk

    def render_png(color_hex, size: 512)
      red, green, blue = color_hex.delete_prefix("#").scan(/../).map { |channel| channel.to_i(16) }
      center = size / 2.0
      radius_squared = (size / 2.0)**2
      raw = String.new(capacity: size * ((size * 4) + 1), encoding: Encoding::BINARY)

      size.times do |y|
        raw << "\x00"

        size.times do |x|
          dx = (x + 0.5) - center
          dy = (y + 0.5) - center

          if (dx * dx) + (dy * dy) <= radius_squared
            raw << [ red, green, blue, 255 ].pack("C4")
          else
            raw << "\x00\x00\x00\x00"
          end
        end
      end

      signature = "\x89PNG\r\n\x1A\n".b
      ihdr = [ size, size, 8, 6, 0, 0, 0 ].pack("NNCCCCC")
      idat = Zlib::Deflate.deflate(raw)

      signature + png_chunk("IHDR", ihdr) + png_chunk("IDAT", idat) + png_chunk("IEND", +"")
    end
    private_class_method :render_png
  end
end
