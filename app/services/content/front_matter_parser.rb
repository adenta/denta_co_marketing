require "psych"
require "yaml"

module Content
  class FrontMatterParser
    ParseError = Class.new(StandardError)
    ParsedDocument = Struct.new(:metadata, :body, keyword_init: true)

    FRONT_MATTER_DELIMITER = "---".freeze

    def parse(source, path: nil)
      text = source.to_s.delete_prefix("\uFEFF")
      lines = text.lines

      raise ParseError, "Missing front matter in #{label_for(path)}" unless lines.first&.chomp == FRONT_MATTER_DELIMITER

      closing_index = lines[1..]&.index { |line| line.chomp == FRONT_MATTER_DELIMITER }
      raise ParseError, "Missing closing front matter delimiter in #{label_for(path)}" unless closing_index

      front_matter_lines = lines[1..closing_index]
      body_lines = lines[(closing_index + 2)..] || []
      metadata = parse_metadata(front_matter_lines.join, path:)

      ParsedDocument.new(metadata:, body: body_lines.join)
    end

    private

    def parse_metadata(front_matter, path:)
      root = Psych.parse(front_matter, filename: label_for(path))&.root
      raise ParseError, "Front matter in #{label_for(path)} must be a YAML mapping" unless root.is_a?(Psych::Nodes::Mapping)

      duplicate_keys = duplicate_keys_for(root)
      raise ParseError, "Duplicate front matter keys in #{label_for(path)}: #{duplicate_keys.join(', ')}" if duplicate_keys.any?

      metadata = YAML.safe_load(front_matter, permitted_classes: [ Date ], aliases: false)
      raise ParseError, "Front matter in #{label_for(path)} must be a YAML mapping" unless metadata.is_a?(Hash)

      metadata.stringify_keys
    rescue Psych::SyntaxError, Psych::AliasesNotEnabled => error
      raise ParseError, "Invalid front matter in #{label_for(path)}: #{error.message}"
    end

    def duplicate_keys_for(root)
      keys = []
      duplicates = []

      root.children.each_slice(2) do |key_node, _value_node|
        key = key_node&.value.to_s
        duplicates << key if keys.include?(key)
        keys << key
      end

      duplicates.uniq
    end

    def label_for(path)
      path.present? ? Pathname(path).basename.to_s : "document"
    end
  end
end
