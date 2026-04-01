module Content
  class MetadataSchema
    ValidationError = Class.new(StandardError)

    def initialize(required:, optional: {})
      @required = required.stringify_keys.freeze
      @optional = optional.stringify_keys.freeze
      @allowed = @required.merge(@optional).freeze
    end

    def validate!(metadata, path:)
      raise ValidationError, "Front matter in #{label_for(path)} must be a Hash" unless metadata.is_a?(Hash)

      normalized = metadata.stringify_keys
      unknown_keys = normalized.keys - @allowed.keys
      raise ValidationError, "Unknown front matter keys in #{label_for(path)}: #{unknown_keys.sort.join(', ')}" if unknown_keys.any?

      missing_keys = @required.keys.reject { |key| present_value?(normalized[key]) }
      raise ValidationError, "Missing #{missing_keys.join(', ')} in #{label_for(path)}" if missing_keys.any?

      @allowed.each_with_object({}) do |(key, type), validated|
        next unless normalized.key?(key)

        validated[key] = validate_type!(key, normalized[key], type:, path:)
      end
    end

    private

    def validate_type!(key, value, type:, path:)
      return nil if value.nil?

      case type
      when :string
        raise ValidationError, "#{key} in #{label_for(path)} must be a String" unless value.is_a?(String)
        raise ValidationError, "#{key} in #{label_for(path)} cannot be blank" if value.blank?

        value
      when :date
        coerce_date!(key, value, path:)
      when :boolean
        raise ValidationError, "#{key} in #{label_for(path)} must be true or false" unless value == true || value == false

        value
      when :string_array
        raise ValidationError, "#{key} in #{label_for(path)} must be an Array of strings" unless value.is_a?(Array) && value.all? { |item| item.is_a?(String) && item.present? }

        value
      else
        raise ArgumentError, "Unsupported metadata type: #{type}"
      end
    end

    def coerce_date!(key, value, path:)
      return value if value.is_a?(Date)
      raise ValidationError, "#{key} in #{label_for(path)} must be an ISO 8601 date" unless value.is_a?(String)

      Date.iso8601(value)
    rescue Date::Error
      raise ValidationError, "#{key} in #{label_for(path)} must be an ISO 8601 date"
    end

    def present_value?(value)
      !(value.nil? || value.respond_to?(:blank?) && value.blank?)
    end

    def label_for(path)
      Pathname(path).basename.to_s
    end
  end
end
