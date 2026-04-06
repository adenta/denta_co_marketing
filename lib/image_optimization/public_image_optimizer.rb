# frozen_string_literal: true

require "fileutils"
require "pathname"
require "tmpdir"
require "vips"

module ImageOptimization
  class PublicImageOptimizer
    OPTIMIZABLE_EXTENSIONS = %w[.jpg .jpeg .png .webp].freeze

    Result = Struct.new(:changed?, :before_bytes, :after_bytes, keyword_init: true)

    def self.optimizable_extension?(path)
      OPTIMIZABLE_EXTENSIONS.include?(Pathname(path).extname.downcase)
    end

    def self.optimize(path)
      source_path = Pathname(path)
      extension = source_path.extname.downcase
      raise ArgumentError, "file does not exist: #{source_path}" unless source_path.file?
      raise ArgumentError, "unsupported file type: #{source_path}" unless optimizable_extension?(source_path)

      before_bytes = source_path.size
      source_mode = source_path.stat.mode
      optimized = false

      Dir.mktmpdir("public-image-optimizer") do |tmpdir|
        tmp_path = Pathname(tmpdir).join(source_path.basename)
        image = Vips::Image.new_from_file(source_path.to_s, access: :sequential)
        image = image.autorot if %w[.jpg .jpeg].include?(extension)

        save_image(image, tmp_path, extension)

        after_bytes = tmp_path.size

        if after_bytes < before_bytes
          File.chmod(source_mode, tmp_path)
          FileUtils.mv(tmp_path, source_path, force: true)
          optimized = true
        end

        return Result.new(changed?: optimized, before_bytes: before_bytes, after_bytes: optimized ? after_bytes : before_bytes)
      end
    end

    class << self
      private

      def save_image(image, destination_path, extension)
        case extension
        when ".jpg", ".jpeg"
          image.jpegsave(
            destination_path.to_s,
            Q: 82,
            strip: true,
            optimize_coding: true,
            interlace: true,
          )
        when ".png"
          image.pngsave(destination_path.to_s, strip: true, compression: 9)
        when ".webp"
          image.webpsave(destination_path.to_s, strip: true, Q: 82, effort: 4)
        else
          raise ArgumentError, "unsupported file type: #{destination_path}"
        end
      end
    end
  end
end
