# frozen_string_literal: true

require "erb"
require "fileutils"
require "json"
require "rails/generators"
require "securerandom"
require "shellwords"
require "yaml"

class MeshGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  BASELINE_NAME = "chat_app"
  DEFAULT_SERVER_IP = "178.156.134.191"
  EXCLUDED_MANAGED_SECRET_KEYS = %w[
    SMTP_EMAIL_ADDRESS
    SMTP_PASSWORD
    SMTP_ADDRESS
    SMTP_PORT
    SMTP_DOMAIN
  ].freeze
  SERVER_IP_PLACEHOLDERS = %w[192.168.0.1].freeze

  desc "Rename this app and rebuild Kamal + 1Password deployment config for the current template"

  argument :new_name, type: :string, desc: "New application name (snake_case)"

  class_option :domain, type: :string, desc: "Production domain for the app"
  class_option :github_username, type: :string, desc: "GitHub username used for GHCR images"
  class_option :onepassword_account, type: :string, desc: "1Password account identifier"
  class_option :registry_source_item, type: :string, default: "Rails-App-Template-Production", desc: "1Password item used to source registry credentials when they are missing from the source app item"
  class_option :server_ip, type: :string, desc: "Primary web server IP address"
  class_option :skip_onepassword, type: :boolean, default: false, desc: "Skip reading and writing 1Password items"
  class_option :source_item, type: :string, default: BASELINE_NAME, desc: "1Password item used as the bootstrap source"
  class_option :vault, type: :string, default: "Personal", desc: "1Password vault name"
  class_option :verbose, type: :boolean, default: false, desc: "Enable verbose logging"

  def rebuild_mesh
    @baseline_name = BASELINE_NAME

    validate_new_name!
    check_prerequisites

    @deployment_config = gather_deployment_config
    rename_application

    @source_secrets = fetch_source_secrets
    @env_vars = parse_env_file
    @secret_key_base = resolve_secret_key_base(@source_secrets)
    @managed_secrets = build_managed_secrets

    ensure_registry_password_present!
    write_env_file

    update_production_configuration
    generate_default_url_options_initializer
    generate_kamal_config
    sync_target_vault_item unless options[:skip_onepassword]

    say_status_with_color "completed", "Mesh rebuild complete for '#{new_name}'", :green
    display_next_steps
  end

  private

  def validate_new_name!
    unless /\A[a-z0-9_]+\z/.match?(new_name)
      raise Thor::Error, "new_name must be snake_case"
    end

    return unless new_name == @baseline_name

    raise Thor::Error, "new_name must differ from #{@baseline_name.inspect}"
  end

  def check_prerequisites
    unless File.exist?(app_path("config/routes.rb"))
      raise Thor::Error, "This does not appear to be a Rails application"
    end

    return if options[:skip_onepassword]
    return if onepassword_cli_available?

    raise Thor::Error, "1Password CLI (op) must be installed and authenticated before running mesh"
  end

  def gather_deployment_config
    {
      domain: option_or_ask(
        :domain,
        prompt: "Domain name",
        missing_label: "domain",
        source: "config/deploy.yml proxy.host/proxy.hosts",
        inferred: inferred_domain
      ),
      github_username: option_or_ask(
        :github_username,
        prompt: "GitHub username",
        missing_label: "GitHub username",
        source: "config/deploy.yml registry.username",
        inferred: inferred_github_username,
        fallback: "adenta"
      ),
      onepassword_account: option_or_ask(
        :onepassword_account,
        prompt: "1Password account ID",
        missing_label: "1Password account ID",
        source: ".kamal/secrets active --account entry",
        inferred: inferred_onepassword_account,
        fallback: "ABOVBJHUF5G2PASRYQTVCYIJKM"
      ),
      registry_source_item: options[:registry_source_item],
      server_ip: option_or_ask(
        :server_ip,
        prompt: "Server IP address",
        missing_label: "server IP address",
        source: "config/deploy.yml servers.web[0]",
        inferred: inferred_server_ip,
        fallback: DEFAULT_SERVER_IP
      ),
      source_item: options[:source_item],
      vault: options[:vault]
    }
  end

  def inferred_domain
    proxy = existing_deploy_config["proxy"]
    return if proxy.nil?

    hosts = proxy["hosts"]
    return hosts.first if hosts.is_a?(Array) && hosts.any?

    proxy["host"]
  end

  def inferred_github_username
    existing_deploy_config.dig("registry", "username")
  end

  def inferred_onepassword_account
    return @inferred_onepassword_account if defined?(@inferred_onepassword_account)

    @inferred_onepassword_account =
      if File.exist?(app_path(".kamal/secrets"))
        active_content = File.readlines(app_path(".kamal/secrets")).reject { |line| line.lstrip.start_with?("#") }.join
        active_content[/--account(?:=|\s+)([A-Za-z0-9_-]+)/, 1]
      end
  end

  def inferred_server_ip
    web = existing_deploy_config.dig("servers", "web")
    return unless web.is_a?(Array)

    candidate = web.first
    return if candidate.blank?
    return if SERVER_IP_PLACEHOLDERS.include?(candidate)

    candidate
  end

  def existing_deploy_config
    @existing_deploy_config ||=
      if File.exist?(app_path("config/deploy.yml"))
        YAML.load_file(app_path("config/deploy.yml")) || {}
      else
        {}
      end
  rescue Psych::SyntaxError
    {}
  end

  def option_or_ask(key, prompt:, source:, inferred:, fallback: nil, missing_label: prompt)
    value = options[key]
    return value if value.present?

    say(prompt_context(prompt:, source:, inferred:, fallback:, missing_label:))

    default = inferred.presence || fallback
    default.present? ? ask("#{prompt}:", default: default) : ask("#{prompt}:")
  end

  def prompt_context(prompt:, source:, inferred:, fallback:, missing_label:)
    if inferred.present?
      "#{prompt} inferred from #{source}: #{inferred}"
    elsif fallback.present?
      "No #{missing_label} found in #{source}; using fallback: #{fallback}"
    else
      "No #{missing_label} found in #{source}; enter a value"
    end
  end

  def rename_application
    old_pascal = @baseline_name.camelize
    old_kebab = @baseline_name.dasherize
    new_pascal = new_name.camelize
    new_kebab = new_name.dasherize
    old_title = @baseline_name.humanize.titleize
    new_title = new_name.humanize.titleize

    update_application_config(old_pascal, new_pascal)
    update_application_layout(old_title, new_title)
    update_auth_shell
    update_pwa_manifest(old_pascal, new_pascal)
    update_dockerfile
    rename_project_placeholders(
      old_name: @baseline_name,
      new_name: new_name,
      old_pascal: old_pascal,
      new_pascal: new_pascal,
      old_title: old_title,
      new_title: new_title,
      old_kebab: old_kebab,
      new_kebab: new_kebab
    )
    update_test_files(
      old_name: @baseline_name,
      new_name: new_name,
      old_pascal: old_pascal,
      new_pascal: new_pascal,
      old_title: old_title,
      new_title: new_title,
      old_kebab: old_kebab,
      new_kebab: new_kebab
    )
  end

  def update_application_config(old_pascal, new_pascal)
    path = "config/application.rb"

    update_file!(path) do |content|
      replace_required(content, "module #{old_pascal}", "module #{new_pascal}", "Rails application module", path)
    end
  end

  def update_application_layout(old_title, new_title)
    path = "app/views/layouts/application.html.erb"

    update_file!(path) do |content|
      content = replace_required(content, /content_for\(:title\) \|\| "#{Regexp.escape(old_title)}"/, %(content_for(:title) || "#{new_title}"), "default application title", path)
      content = replace_required(content, /content="#{Regexp.escape(old_title)}"/, %(content="#{new_title}"), "application-name meta tag", path)
      replace_required(content, %(app_name: "chat_app"), %(app_name: "#{new_name}"), "navbar app name prop", path)
    end
  end

  def update_auth_shell
    path = "app/javascript/components/auth/auth-shell.tsx"

    update_file!(path) do |content|
      replace_required(content, "chat_app", new_name, "auth shell brand", path)
    end
  end

  def update_pwa_manifest(old_pascal, new_pascal)
    path = "app/views/pwa/manifest.json.erb"

    update_file!(path) do |content|
      content = replace_required(content, %("name": "#{old_pascal}"), %("name": "#{new_pascal}"), "PWA manifest name", path)
      replace_required(content, %("description": "#{old_pascal}."), %("description": "#{new_pascal}."), "PWA manifest description", path)
    end
  end

  def update_dockerfile
    path = "Dockerfile"

    update_file!(path) do |content|
      content = replace_required(content, "# docker build -t #{@baseline_name} .", "# docker build -t #{new_name} .", "Docker build example", path)
      replace_required(content, "--name #{@baseline_name} #{@baseline_name}", "--name #{new_name} #{new_name}", "Docker run example", path)
    end
  end

  def rename_project_placeholders(old_name:, new_name:, old_pascal:, new_pascal:, old_title:, new_title:, old_kebab:, new_kebab:)
    replace_name_variants_in_files(renameable_project_files, name_replacements(
      old_name: old_name,
      new_name: new_name,
      old_pascal: old_pascal,
      new_pascal: new_pascal,
      old_title: old_title,
      new_title: new_title,
      old_kebab: old_kebab,
      new_kebab: new_kebab
    ))
  end

  def update_test_files(old_name:, new_name:, old_pascal:, new_pascal:, old_title:, new_title:, old_kebab:, new_kebab:)
    replace_name_variants_in_files(renameable_test_files, name_replacements(
      old_name: old_name,
      new_name: new_name,
      old_pascal: old_pascal,
      new_pascal: new_pascal,
      old_title: old_title,
      new_title: new_title,
      old_kebab: old_kebab,
      new_kebab: new_kebab
    ))
  end

  def renameable_project_files
    explicit_paths = %w[README.md Dockerfile]
    globbed_paths = [
      "app/**/*.{rb,erb,js,jsx,ts,tsx,json}",
      "config/**/*.{rb,yml,erb}"
    ].flat_map { |pattern| Dir.glob(app_path(pattern)) }

    (explicit_paths.map { |path| app_path(path) } + globbed_paths).uniq.select { |path| File.file?(path) }.sort
  end

  def renameable_test_files
    Dir.glob(app_path("test/**/*.{rb,yml,erb,js,jsx,ts,tsx,json}")).select { |path| File.file?(path) }.sort
  end

  def replace_name_variants_in_files(paths, replacements)
    paths.each do |full_path|
      content = File.read(full_path)
      updated = apply_replacements(content, replacements)
      next if updated == content

      File.write(full_path, updated)
      say_status_with_color "updated", relative_path(full_path), :green
    end
  end

  def apply_replacements(content, replacements)
    replacements.reduce(content) do |updated, (from, to)|
      updated.gsub(from, to)
    end
  end

  def name_replacements(old_name:, new_name:, old_pascal:, new_pascal:, old_title:, new_title:, old_kebab:, new_kebab:)
    [
      [ old_title, new_title ],
      [ old_pascal, new_pascal ],
      [ old_kebab, new_kebab ],
      [ old_name.upcase, new_name.upcase ],
      [ old_name, new_name ]
    ]
  end

  def relative_path(full_path)
    full_path.delete_prefix("#{destination_root}/")
  end

  def fetch_source_secrets
    return {} if options[:skip_onepassword]

    say_status_with_color "reading", "Reading source secrets from #{@deployment_config[:vault]}/#{@deployment_config[:source_item]}", :blue

    secrets = fetch_all_secrets_from_vault(@deployment_config[:source_item])
    if secrets.empty?
      say_status_with_color "warning", "No concealed fields found in #{@deployment_config[:vault]}/#{@deployment_config[:source_item]}", :yellow
    end

    if secrets["KAMAL_REGISTRY_PASSWORD"].blank?
      fallback = fetch_secret_from_vault("KAMAL_REGISTRY_PASSWORD", @deployment_config[:registry_source_item])
      secrets["KAMAL_REGISTRY_PASSWORD"] = fallback if fallback.present?
    end

    secrets
  end

  def parse_env_file
    return {} unless File.exist?(app_path(".env"))

    env_vars = {}

    File.readlines(app_path(".env"), chomp: true).each do |line|
      next if line.strip.empty? || line.start_with?("#")

      key, value = line.split("=", 2)
      next if key.blank? || value.nil?

      env_vars[key] = value
    end

    env_vars
  end

  def resolve_secret_key_base(source_secrets)
    return @env_vars["SECRET_KEY_BASE"] if @env_vars["SECRET_KEY_BASE"].present?
    return source_secrets["SECRET_KEY_BASE"] if source_secrets["SECRET_KEY_BASE"].present?

    generated = SecureRandom.hex(64)
    say_status_with_color "generated", "SECRET_KEY_BASE", :green
    generated
  end

  def build_managed_secrets
    managed = @source_secrets.dup

    @env_vars.each do |key, value|
      managed[key] = value if managed[key].blank?
    end

    managed["SECRET_KEY_BASE"] = @secret_key_base
    EXCLUDED_MANAGED_SECRET_KEYS.each { |key| managed.delete(key) }
    managed.delete_if { |_key, value| value.blank? }
    managed
  end

  def write_env_file
    env_assignments = ordered_secret_keys(@managed_secrets.keys - [ "SECRET_KEY_BASE" ]).map do |key|
      %(#{key}=#{@managed_secrets.fetch(key)})
    end

    content = env_assignments.join("\n")
    content = "#{content}\n" if content.present?

    File.write(app_path(".env"), content)
    say_status_with_color "created", ".env", :green
  end

  def ensure_registry_password_present!
    return if @managed_secrets["KAMAL_REGISTRY_PASSWORD"].present?

    raise Thor::Error, "KAMAL_REGISTRY_PASSWORD is required. Add it to .env or to #{@deployment_config[:vault]}/#{@deployment_config[:source_item]} (or #{@deployment_config[:registry_source_item]})"
  end

  def update_production_configuration
    path = "config/environments/production.rb"

    update_file!(path) do |content|
      content = replace_required(content, /^\s*#\s*config\.assume_ssl = true$/, "  config.assume_ssl = true", "config.assume_ssl setting", path)
      content = replace_required(content, /^\s*#\s*config\.force_ssl = true$/, "  config.force_ssl = true", "config.force_ssl setting", path)
      replace_required(content, /^\s*config\.action_mailer\.default_url_options = \{ host: "example\.com" \}\n/, "", "hard-coded mailer host", path)
    end
  end

  def generate_default_url_options_initializer
    initializer = <<~RUBY
      # frozen_string_literal: true

      hosts = {
        development: "localhost:3000",
        test: "example.com",
        production: #{@deployment_config[:domain].inspect}
      }.freeze

      protocols = {
        development: "http",
        test: "http",
        production: "https"
      }.freeze

      Rails.application.config.to_prepare do
        env = Rails.env.to_sym
        route_options = {
          host: hosts.fetch(env),
          protocol: protocols.fetch(env)
        }

        Rails.application.routes.default_url_options = route_options.dup
        Rails.application.config.action_mailer.default_url_options = route_options.dup
        ActiveStorage::Current.url_options = route_options.dup if defined?(ActiveStorage::Current)
      end
    RUBY

    FileUtils.mkdir_p(File.dirname(app_path("config/initializers/default_url_options.rb")))
    File.write(app_path("config/initializers/default_url_options.rb"), initializer)
    say_status_with_color "created", "config/initializers/default_url_options.rb", :green
  end

  def generate_kamal_config
    FileUtils.mkdir_p(app_path(".kamal"))

    env_secret_keys = managed_env_secret_keys
    builder_secret_keys = managed_builder_secret_keys

    deploy_content = render_template(
      "kamal/deploy.yml.tt",
      app_name: new_name,
      builder_secret_keys: builder_secret_keys,
      domain: @deployment_config[:domain],
      env_secret_keys: env_secret_keys,
      github_username: @deployment_config[:github_username],
      server_ip: @deployment_config[:server_ip],
    )

    secrets_content = render_template(
      "kamal/secrets.tt",
      app_name: new_name,
      onepassword_account: @deployment_config[:onepassword_account],
      secret_keys: managed_secret_keys,
      vault: @deployment_config[:vault],
    )

    File.write(app_path("config/deploy.yml"), deploy_content)
    File.write(app_path(".kamal/secrets"), secrets_content)

    say_status_with_color "created", "config/deploy.yml", :green
    say_status_with_color "created", ".kamal/secrets", :green
  end

  def managed_secret_keys
    ordered_secret_keys(@managed_secrets.keys)
  end

  def managed_env_secret_keys
    managed_secret_keys - %w[KAMAL_REGISTRY_PASSWORD GITHUB_TOKEN]
  end

  def managed_builder_secret_keys
    @managed_secrets["KAMAL_REGISTRY_PASSWORD"].present? ? [ "GITHUB_TOKEN" ] : []
  end

  def ordered_secret_keys(keys)
    priority = %w[
      KAMAL_REGISTRY_PASSWORD
      SECRET_KEY_BASE
      OPENROUTER_API_KEY
      TWILIO_ACCOUNT_SID
      TWILIO_ACCOUNT_TOKEN
      TWILIO_PHONE_NUMBER
    ]

    remaining = keys.dup
    ordered = priority.each_with_object([]) do |key, result|
      next unless remaining.delete(key)

      result << key
    end

    ordered + remaining.sort
  end

  def sync_target_vault_item
    say_status_with_color "writing", "Syncing #{@deployment_config[:vault]}/#{new_name} in 1Password", :blue

    assignments = @managed_secrets.map do |key, value|
      "#{key}[password]=#{value}"
    end

    if vault_item_exists?(new_name)
      edit_cmd = [ "op", "item", "edit", new_name, "--vault", @deployment_config[:vault] ]
      edit_cmd += [ "--account", @deployment_config[:onepassword_account] ] if @deployment_config[:onepassword_account].present?
      edit_cmd.concat(assignments)
      run_command!(edit_cmd, "Failed to update #{@deployment_config[:vault]}/#{new_name}")
      say_status_with_color "updated", "#{@deployment_config[:vault]}/#{new_name}", :green
    else
      create_cmd = [ "op", "item", "create", "--category", "password", "--title", new_name, "--vault", @deployment_config[:vault] ]
      create_cmd += [ "--account", @deployment_config[:onepassword_account] ] if @deployment_config[:onepassword_account].present?
      create_cmd.concat(assignments)
      run_command!(create_cmd, "Failed to create #{@deployment_config[:vault]}/#{new_name}")
      say_status_with_color "created", "#{@deployment_config[:vault]}/#{new_name}", :green
    end
  end

  def vault_item_exists?(item_title)
    cmd = [ "op", "item", "get", item_title, "--vault", @deployment_config[:vault], "--format", "json" ]
    cmd += [ "--account", @deployment_config[:onepassword_account] ] if @deployment_config[:onepassword_account].present?
    system(*cmd, out: File::NULL, err: File::NULL)
  end

  def run_command!(cmd, error_message)
    return if system(*cmd, out: File::NULL, err: File::NULL)

    raise Thor::Error, error_message
  end

  def fetch_secret_from_vault(secret_key, item_title)
    cmd = [ "op", "item", "get", item_title, "--vault", @deployment_config[:vault], "--fields", secret_key, "--reveal" ]
    cmd += [ "--account", @deployment_config[:onepassword_account] ] if @deployment_config[:onepassword_account].present?
    value = `#{Shellwords.join(cmd)} 2>/dev/null`.strip
    value.presence
  end

  def fetch_all_secrets_from_vault(item_title)
    cmd = [ "op", "item", "get", item_title, "--vault", @deployment_config[:vault], "--format", "json" ]
    cmd += [ "--account", @deployment_config[:onepassword_account] ] if @deployment_config[:onepassword_account].present?

    json_output = `#{Shellwords.join(cmd)} 2>/dev/null`.strip
    return {} if json_output.blank?

    item = JSON.parse(json_output)
    fields = item.fetch("fields", [])

    extract_item_fields(fields)
  rescue JSON::ParserError => error
    say "Could not parse secrets from #{item_title}: #{error.message}", :yellow if options[:verbose]
    {}
  end

  def extract_item_fields(fields)
    fields.each_with_object({}) do |field, result|
      next if field["label"].blank? || field["value"].blank?

      result[field["label"]] = field["value"]
    end
  end

  def onepassword_cli_available?
    system("op --version > /dev/null 2>&1") && system("op account list > /dev/null 2>&1")
  end

  def render_template(template_path, locals = {})
    template_file = File.join(self.class.source_root, template_path)
    template = ERB.new(File.read(template_file), trim_mode: "-")
    context = binding

    locals.each do |key, value|
      context.local_variable_set(key, value)
    end

    template.result(context)
  end

  def update_file!(path)
    full_path = app_path(path)
    content = File.read(full_path)
    updated = yield(content)
    File.write(full_path, updated) if updated != content
    say_status_with_color "updated", path, :green
  end

  def app_path(path)
    File.join(destination_root, path)
  end

  def replace_required(content, pattern, replacement, description, path)
    matched =
      if pattern.is_a?(Regexp)
        content.match?(pattern)
      else
        content.include?(pattern)
      end

    return content.gsub(pattern, replacement) if matched

    raise Thor::Error, "Expected #{description} in #{path}"
  end

  def display_next_steps
    say ""
    say "Next steps:", :yellow
    say "  1. Review config/deploy.yml and confirm the server IP, domain, and GHCR username.", :white
    say "  2. Verify #{@deployment_config[:vault]}/#{new_name} contains the expected secrets.", :white
    say "  3. Run 'kamal setup' and then 'kamal deploy' when the target server is ready.", :white
  end

  def say_status_with_color(status, message, color = :green)
    say "#{status.ljust(12)} #{message}", color
  end
end
