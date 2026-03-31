# frozen_string_literal: true

require "json"
require "open3"
require "shellwords"

module Setup
  module OnePasswordSecretResolver
    ENV_STYLE_KEY_PATTERN = /\A[A-Z0-9_]+\z/

    Source = Struct.new(:vault, :item, :account, keyword_init: true)
    ExtractMapping = Struct.new(:environment_key, :field_name, keyword_init: true)

    module_function

    def source_from_kamal_secrets(path)
      return unless File.exist?(path)

      command = extract_fetch_command(File.read(path))
      return unless command

      args = Shellwords.split(command)
      return unless onepassword_fetch_command?(args)

      from_index = args.index("--from")
      return unless from_index

      from_value = args[from_index + 1]
      return if from_value.to_s.empty?

      vault, item = from_value.split("/", 2)
      return if vault.to_s.empty? || item.to_s.empty?

      account_index = args.index("--account")

      Source.new(
        vault: vault,
        item: item,
        account: account_index ? args[account_index + 1] : nil,
      )
    rescue ArgumentError
      nil
    end

    def fetch_from_kamal_secrets(path, field_name)
      source = source_from_kamal_secrets(path)
      return if source.nil?

      fetch_field(
        field_name,
        vault: source.vault,
        item: source.item,
        account: source.account,
      )
    end

    def extract_mappings_from_kamal_secrets(path)
      return [] unless File.exist?(path)

      File.read(path).each_line.filter_map do |line|
        stripped = line.strip
        next if stripped.empty? || stripped.start_with?("#", "SECRETS=$(")

        match = stripped.match(/\A([A-Z0-9_]+)=\$\(\s*kamal\s+secrets\s+extract\s+([A-Z0-9_]+)\s+\$\{SECRETS\}\s*\)\z/)
        next unless match

        ExtractMapping.new(environment_key: match[1], field_name: match[2])
      end
    end

    def fetch_env_values_from_kamal_secrets(path, exclude_keys: [])
      source = source_from_kamal_secrets(path)
      return {} if source.nil?

      cache = {}

      extract_mappings_from_kamal_secrets(path).each_with_object({}) do |mapping, result|
        next if exclude_keys.include?(mapping.environment_key)

        value =
          cache.fetch(mapping.field_name) do
            cache[mapping.field_name] = fetch_field(
              mapping.field_name,
              vault: source.vault,
              item: source.item,
              account: source.account,
            )
          end

        result[mapping.environment_key] = value if !value.nil? && !value.empty?
      end
    end

    def fetch_env_values_from_item(vault:, item:, account: nil, exclude_keys: [])
      item_data = fetch_item(vault: vault, item: item, account: account)
      return {} if item_data.nil?

      extract_env_values_from_item_fields(
        item_data.fetch("fields", []),
        exclude_keys: exclude_keys,
      )
    end

    def fetch_field(field_name, vault:, item:, account: nil)
      cmd = [ "op", "item", "get", item, "--vault", vault, "--fields", field_name, "--reveal" ]
      cmd += [ "--account", account ] if account.to_s.strip != ""

      output, status = Open3.capture2e(*cmd)
      return unless status.success?

      value = output.strip
      value.empty? ? nil : value
    rescue Errno::ENOENT
      nil
    end

    def fetch_item(vault:, item:, account: nil)
      cmd = [ "op", "item", "get", item, "--vault", vault, "--format", "json" ]
      cmd += [ "--account", account ] if account.to_s.strip != ""

      output, status = Open3.capture2e(*cmd)
      return unless status.success?

      JSON.parse(output)
    rescue Errno::ENOENT, JSON::ParserError
      nil
    end
    private_class_method :fetch_item

    def extract_env_values_from_item_fields(fields, exclude_keys: [])
      fields.each_with_object({}) do |field, result|
        label = field["label"].to_s
        value = field["value"].to_s

        next if label.empty? || value.empty?
        next unless label.match?(ENV_STYLE_KEY_PATTERN)
        next if exclude_keys.include?(label)

        result[label] = value
      end
    end
    private_class_method :extract_env_values_from_item_fields

    def extract_fetch_command(content)
      content.each_line do |line|
        stripped = line.strip
        next if stripped.empty? || stripped.start_with?("#")
        next unless stripped.start_with?("SECRETS=$(") && stripped.end_with?(")")

        return stripped.delete_prefix("SECRETS=$(").delete_suffix(")")
      end

      nil
    end
    private_class_method :extract_fetch_command

    def onepassword_fetch_command?(args)
      args[0, 5] == [ "kamal", "secrets", "fetch", "--adapter", "1password" ]
    end
    private_class_method :onepassword_fetch_command?
  end
end
