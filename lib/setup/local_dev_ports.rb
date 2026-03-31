# frozen_string_literal: true

require "digest"
require "socket"

module Setup
  module LocalDevPorts
    PORT_KEY = "PORT"
    VITE_PORT_KEY = "VITE_RUBY_PORT"
    VITE_PORT_OFFSET = 36
    RAILS_PORT_RANGE = (3000..3963)
    OCCUPIED_PORTS_ENV = "CODEX_SETUP_OCCUPIED_PORTS"

    module_function

    def preferred_ports_for_root(root)
      rails_port = candidate_rails_ports(root).first

      {
        PORT_KEY => rails_port,
        VITE_PORT_KEY => rails_port + VITE_PORT_OFFSET
      }
    end

    def ensure_env_file_ports(path, root:)
      lines = File.exist?(path) ? File.readlines(path, chomp: false) : []
      env_vars = parse_env_lines(lines)

      ports = resolve_ports(root: root, env_vars: env_vars)
      updated_lines = upsert_port_lines(lines, ports)

      File.write(path, updated_lines.join) if updated_lines != lines

      ports.transform_values(&:to_s)
    end

    def parse_env_lines(lines)
      lines.each_with_object({}) do |line, env_vars|
        stripped = line.strip
        next if stripped.empty? || stripped.start_with?("#")

        stripped = stripped.sub(/\Aexport\s+/, "")
        key, raw_value = stripped.split("=", 2)
        next if key.to_s.empty? || raw_value.nil?

        env_vars[key] = parse_env_value(raw_value)
      end
    end

    def parse_env_value(raw_value)
      value = raw_value.strip

      if value.start_with?('"') && value.end_with?('"')
        value[1...-1].gsub(/\\(["\\])/, '\1')
      elsif value.start_with?("'") && value.end_with?("'")
        value[1...-1]
      else
        value.split(/\s+#/, 2).first.to_s.strip
      end
    end

    def resolve_ports(root:, env_vars:)
      rails_port = parse_existing_port(env_vars, PORT_KEY)
      vite_port = parse_existing_port(env_vars, VITE_PORT_KEY)

      return { PORT_KEY => rails_port, VITE_PORT_KEY => vite_port } if rails_port && vite_port
      return resolve_missing_vite_port(rails_port) if rails_port
      return resolve_missing_rails_port(vite_port) if vite_port

      candidate_rails_ports(root).each do |candidate|
        vite_candidate = candidate + VITE_PORT_OFFSET
        next unless port_available?(candidate) && port_available?(vite_candidate)

        return {
          PORT_KEY => candidate,
          VITE_PORT_KEY => vite_candidate
        }
      end

      raise "No free local development port pair is available in #{RAILS_PORT_RANGE.begin}-#{RAILS_PORT_RANGE.end + VITE_PORT_OFFSET}"
    end

    def resolve_missing_vite_port(rails_port)
      vite_port = rails_port + VITE_PORT_OFFSET
      return { PORT_KEY => rails_port, VITE_PORT_KEY => vite_port } if port_available?(vite_port)

      raise "#{VITE_PORT_KEY} is missing and the paired port #{vite_port} is already in use. Set #{VITE_PORT_KEY} explicitly in .env or free that port."
    end

    def resolve_missing_rails_port(vite_port)
      rails_port = vite_port - VITE_PORT_OFFSET
      unless RAILS_PORT_RANGE.cover?(rails_port) && port_available?(rails_port)
        raise "#{PORT_KEY} is missing and no free paired Rails port can be derived from #{VITE_PORT_KEY}=#{vite_port}. Set #{PORT_KEY} explicitly in .env."
      end

      {
        PORT_KEY => rails_port,
        VITE_PORT_KEY => vite_port
      }
    end

    def parse_existing_port(env_vars, key)
      value = env_vars[key]
      return unless value

      Integer(value, 10)
    rescue ArgumentError
      raise "#{key} must be an integer in .env, got #{value.inspect}"
    end

    def candidate_rails_ports(root)
      candidates = RAILS_PORT_RANGE.to_a
      start_index = Digest::SHA256.hexdigest(File.expand_path(root)).to_i(16) % candidates.length

      candidates.rotate(start_index)
    end

    def port_available?(port)
      return false if occupied_ports_from_env.include?(port)

      socket = Socket.tcp("127.0.0.1", port, connect_timeout: 0.1)
      socket.close
      false
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EPERM, SocketError
      true
    end

    def upsert_port_lines(lines, ports)
      updated = lines.dup

      [ PORT_KEY, VITE_PORT_KEY ].each do |key|
        value = ports.fetch(key)
        line = "#{key}=#{value}\n"
        index = updated.index { |existing| existing.match?(/\A\s*(?:export\s+)?#{Regexp.escape(key)}=/) }

        if index
          updated[index] = line
        else
          updated << line
        end
      end

      updated
    end

    def occupied_ports_from_env
      ENV.fetch(OCCUPIED_PORTS_ENV, "").split(",").filter_map do |value|
        next if value.strip.empty?

        Integer(value, 10)
      rescue ArgumentError
        nil
      end
    end
  end
end
