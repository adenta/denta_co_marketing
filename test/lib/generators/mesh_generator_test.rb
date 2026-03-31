# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/mesh/mesh_generator"

class MeshGeneratorTest < Rails::Generators::TestCase
  tests MeshGenerator
  destination Rails.root.join("tmp/generators/mesh")
  setup :prepare_destination

  def setup
    super

    copy_fixture("config/routes.rb")
    copy_fixture("config/application.rb")
    copy_fixture("config/environments/production.rb")
    copy_fixture("config/deploy.yml")
    copy_fixture("README.md")
    copy_fixture("app/views/layouts/application.html.erb")
    copy_fixture("app/views/pwa/manifest.json.erb")
    copy_fixture("app/javascript/components/auth/auth-shell.tsx")
    copy_fixture("Dockerfile")
    write_fixture("app/javascript/pages/home/index.tsx", <<~TSX)
      import { CardTitle } from "@/components/ui/card";

      export default function HomeIndex() {
        return <CardTitle>Denta Co Marketing</CardTitle>;
      }
    TSX

    File.write(destination_root.join(".env"), <<~ENV)
      OPENROUTER_API_KEY=test-openrouter-key
      KAMAL_REGISTRY_PASSWORD=test-registry-token
      POSTMARK_API_TOKEN=test-postmark-token
      SMTP_PASSWORD=test-smtp-password
    ENV
  end

  test "rebuilds mesh for this app structure" do
    assert_nothing_raised do
      run_generator [
        "midwest_dads",
        "--domain", "midwest-dads.example.com",
        "--github-username", "adenta",
        "--server-ip", "203.0.113.10",
        "--onepassword-account", "ABCD1234",
        "--skip-onepassword"
      ]
    end

    assert_file "config/application.rb", /module MidwestDads/
    assert_file "app/views/layouts/application.html.erb", /"Midwest Dads"/
    assert_file "app/views/layouts/application.html.erb", /app_name: "midwest_dads"/
    assert_file "app/javascript/components/auth/auth-shell.tsx", /midwest_dads/
    assert_file "app/javascript/pages/home/index.tsx", /<CardTitle>Midwest Dads<\/CardTitle>/
    assert_file "app/views/pwa/manifest.json.erb", /"name": "MidwestDads"/
    assert_file "Dockerfile", /docker build -t midwest_dads/
    assert_file "README.md", /^# Midwest Dads$/

    assert_file "config/environments/production.rb", /config\.assume_ssl = true/
    assert_file "config/environments/production.rb", /config\.force_ssl = true/
    assert_no_file_line "config/environments/production.rb", /default_url_options = \{ host: "example\.com" \}/

    assert_file "config/initializers/default_url_options.rb", /production: "midwest-dads\.example\.com"/
    assert_file "config/deploy.yml", /^service: midwest_dads$/
    assert_file "config/deploy.yml", /^image: adenta\/midwest_dads$/
    assert_file "config/deploy.yml", /^\s+- SECRET_KEY_BASE$/
    assert_file "config/deploy.yml", /^\s+- OPENROUTER_API_KEY$/
    assert_file "config/deploy.yml", /^\s+- POSTMARK_API_TOKEN$/
    assert_file "config/deploy.yml", /^\s+remote: ssh:\/\/root@203\.0\.113\.10$/
    assert_file ".kamal/secrets", /--from Personal\/midwest_dads/
    assert_file ".kamal/secrets", /^SECRET_KEY_BASE=\$\(kamal secrets extract SECRET_KEY_BASE \$\{SECRETS\}\)$/
    assert_file ".kamal/secrets", /^OPENROUTER_API_KEY=\$\(kamal secrets extract OPENROUTER_API_KEY \$\{SECRETS\}\)$/
    assert_file ".kamal/secrets", /^POSTMARK_API_TOKEN=\$\(kamal secrets extract POSTMARK_API_TOKEN \$\{SECRETS\}\)$/
    assert_file ".kamal/secrets", /^GITHUB_TOKEN=\$\(kamal secrets extract KAMAL_REGISTRY_PASSWORD \$\{SECRETS\}\)$/
    assert_file ".env", /^KAMAL_REGISTRY_PASSWORD=test-registry-token$/
    assert_file ".env", /^OPENROUTER_API_KEY=test-openrouter-key$/
    assert_file ".env", /^POSTMARK_API_TOKEN=test-postmark-token$/
    assert_no_file_line ".env", /^SECRET_KEY_BASE=/
    assert_no_file_line "config/deploy.yml", /^\s+- SMTP_PASSWORD$/
    assert_no_file_line ".kamal/secrets", /^SMTP_PASSWORD=/
    assert_no_file_line ".env", /^SMTP_PASSWORD=/

    assert_no_baseline_name_variants_in_app_files
  end

  test "extract_item_fields keeps labeled non-null values regardless of field type" do
    generator = generator_class.new(
      [ "midwest_dads" ],
      {},
      destination_root: destination_root
    )

    fields = [
      { "label" => "SECRET_KEY_BASE", "type" => "STRING", "value" => "vault-secret-key-base" },
      { "label" => "SMTP_PASSWORD", "type" => "CONCEALED", "value" => "smtp-secret" },
      { "label" => "notesPlain", "type" => "STRING", "value" => nil },
      { "label" => "EMPTY_VALUE", "type" => "STRING", "value" => "" },
      { "label" => nil, "type" => "STRING", "value" => "ignored" }
    ]

    extracted = generator.send(:extract_item_fields, fields)

    assert_equal(
      {
        "SECRET_KEY_BASE" => "vault-secret-key-base",
        "SMTP_PASSWORD" => "smtp-secret"
      },
      extracted
    )
  end

  test "uses SECRET_KEY_BASE from source secrets when local env is missing" do
    FileUtils.rm_f(destination_root.join(".env"))

    generator = generator_class.new(
      [ "midwest_dads" ],
      {
        domain: "midwest-dads.example.com",
        github_username: "adenta",
        server_ip: "203.0.113.10",
        onepassword_account: "ABCD1234"
      },
      destination_root: destination_root
    )

    generator.singleton_class.send(:define_method, :check_prerequisites) { true }
    generator.singleton_class.send(:define_method, :fetch_all_secrets_from_vault) do |_item_title|
      {
        "SECRET_KEY_BASE" => "vault-secret-key-base",
        "KAMAL_REGISTRY_PASSWORD" => "test-registry-token",
        "POSTMARK_API_TOKEN" => "test-postmark-token",
        "SMTP_PASSWORD" => "smtp-secret"
      }
    end
    generator.singleton_class.send(:define_method, :sync_target_vault_item) { true }

    assert_nothing_raised do
      capture(:stdout) do
        Dir.chdir(destination_root) do
          generator.rebuild_mesh
        end
      end
    end

    assert_file ".env", /^KAMAL_REGISTRY_PASSWORD=test-registry-token$/
    assert_file ".env", /^POSTMARK_API_TOKEN=test-postmark-token$/
    assert_file "config/deploy.yml", /^\s+- POSTMARK_API_TOKEN$/
    assert_file "config/deploy.yml", /^\s+- SECRET_KEY_BASE$/
    assert_file ".kamal/secrets", /^SECRET_KEY_BASE=\$\(kamal secrets extract SECRET_KEY_BASE \$\{SECRETS\}\)$/
    assert_file ".kamal/secrets", /^POSTMARK_API_TOKEN=\$\(kamal secrets extract POSTMARK_API_TOKEN \$\{SECRETS\}\)$/
    assert_no_file_line ".env", /^SECRET_KEY_BASE=/
    assert_no_file_line ".env", /^SMTP_PASSWORD=/
    assert_no_file_line "config/deploy.yml", /^\s+- SMTP_PASSWORD$/
    assert_no_file_line ".kamal/secrets", /^SMTP_PASSWORD=/
  end

  test "interactive prompts explain hardcoded fallbacks when config values are missing" do
    File.write(destination_root.join("config/deploy.yml"), <<~YAML)
      service: denta_co_marketing
      image: denta_co_marketing
      servers:
        web:
          - 192.168.0.1
      registry:
        server: ghcr.io
    YAML

    write_fixture(".kamal/secrets", <<~SECRETS)
      # SECRETS=$(kamal secrets fetch --adapter 1password --account your-account --from Personal/denta_co_marketing SECRET_KEY_BASE)
      SECRET_KEY_BASE=$SECRET_KEY_BASE
    SECRETS

    output = capture_prompt_output(
      [
        "midwest_dads",
        "--pretend",
        "--skip-onepassword"
      ],
      responses: [ "video_studio.midwestdads.com", "", "", "" ]
    )

    assert_includes output, "No domain found in config/deploy.yml proxy.host/proxy.hosts; enter a value"
    assert_includes output, "No GitHub username found in config/deploy.yml registry.username; using fallback: adenta"
    assert_includes output, "No 1Password account ID found in .kamal/secrets active --account entry; using fallback: ABOVBJHUF5G2PASRYQTVCYIJKM"
    assert_includes output, "No server IP address found in config/deploy.yml servers.web[0]; using fallback: 178.156.134.191"
    refute_includes output, "your-account"
  end

  test "interactive prompts identify inferred values and their sources" do
    File.write(destination_root.join("config/deploy.yml"), <<~YAML)
      service: denta_co_marketing
      image: denta_co_marketing
      proxy:
        host: video_studio.midwestdads.com
      registry:
        server: ghcr.io
        username: adenta
      servers:
        web:
          - 203.0.113.10
    YAML

    write_fixture(".kamal/secrets", <<~SECRETS)
      SECRETS=$(kamal secrets fetch --adapter 1password --account ACCOUNT123 --from Personal/denta_co_marketing SECRET_KEY_BASE)
      SECRET_KEY_BASE=$(kamal secrets extract SECRET_KEY_BASE ${SECRETS})
    SECRETS

    output = capture_prompt_output(
      [
        "midwest_dads",
        "--pretend",
        "--skip-onepassword"
      ],
      responses: [ "", "", "", "" ]
    )

    assert_includes output, "Domain name inferred from config/deploy.yml proxy.host/proxy.hosts: video_studio.midwestdads.com"
    assert_includes output, "GitHub username inferred from config/deploy.yml registry.username: adenta"
    assert_includes output, "1Password account ID inferred from .kamal/secrets active --account entry: ACCOUNT123"
    assert_includes output, "Server IP address inferred from config/deploy.yml servers.web[0]: 203.0.113.10"
  end

  private

  def copy_fixture(relative_path)
    source = Rails.root.join(relative_path)
    target = destination_root.join(relative_path)
    FileUtils.mkdir_p(target.dirname)
    FileUtils.cp(source, target)
  end

  def write_fixture(relative_path, content)
    target = destination_root.join(relative_path)
    FileUtils.mkdir_p(target.dirname)
    File.write(target, content)
  end

  def capture_prompt_output(args, responses:)
    remaining_responses = responses.dup
    readline = lambda do |prompt, *_args|
      $stdout.print(prompt)
      remaining_responses.shift
    end

    original_readline = Thor::LineEditor.method(:readline)

    Thor::LineEditor.singleton_class.define_method(:readline, &readline)

    output = capture(:stdout) do
      begin
        generator_class.start(args, destination_root: destination_root)
      ensure
        Thor::LineEditor.singleton_class.define_method(:readline, original_readline)
      end
    end

    assert_empty remaining_responses
    output
  end

  def assert_no_file_line(path, pattern)
    refute_match pattern, File.read(File.join(destination_root, path))
  end

  def assert_no_baseline_name_variants_in_app_files
    candidate_files = [
      destination_root.join("README.md"),
      destination_root.join("Dockerfile"),
      *Dir.glob(destination_root.join("app/**/*.{rb,erb,js,jsx,ts,tsx,json}")),
      *Dir.glob(destination_root.join("config/**/*.{rb,yml,erb}"))
    ]

    candidate_files.each do |file|
      next unless File.file?(file)

      refute_match(/denta_co_marketing|DentaCoMarketing|Denta Co Marketing|denta-co-marketing|DENTA_CO_MARKETING/, File.read(file), "#{file} still contains a baseline app-name variant")
    end
  end
end
