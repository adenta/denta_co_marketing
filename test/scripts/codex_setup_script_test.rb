# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "test_helper"
require "tmpdir"
require "setup/local_dev_ports"

class CodexSetupScriptTest < ActiveSupport::TestCase
  test "refreshes models with OPENROUTER_API_KEY from Personal/codex_local_workspace" do
    with_fake_codex_app do |root|
      refute root.join(".kamal/secrets").exist?
      write_fake_op(
        root,
        fields: {
          "OPENROUTER_API_KEY" => "test-openrouter-key",
          "FAL_KEY" => "test-fal-key",
          "KAMAL_REGISTRY_PASSWORD" => "test-registry-token",
          "notesPlain" => "ignored-note",
          "hyphen-key" => "ignored-hyphen",
          "EMPTY_VALUE" => ""
        },
      )

      stdout, stderr, status = run_setup_script(root)

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match "Setup complete.", stdout
      assert_equal(
        [ "runner Model.refresh!" ],
        rails_log_lines(root, "rails-args.log"),
      )
      assert_equal(
        [ "OPENROUTER_API_KEY=test-openrouter-key", "FAL_KEY=" ],
        rails_log_lines(root, "rails-env.log"),
      )
      assert_equal(
        [ "item get codex_local_workspace --vault Personal --format json" ],
        rails_log_lines(root, "op-args.log"),
      )
      assert_match(/Configured local dev ports: Rails \d+, Vite \d+/, stdout)
      assert_match(/^OPENROUTER_API_KEY=test-openrouter-key$/, root.join(".env").read)
      assert_match(/^FAL_KEY=test-fal-key$/, root.join(".env").read)
      assert_match(/^KAMAL_REGISTRY_PASSWORD=test-registry-token$/, root.join(".env").read)
      assert_match(/^PORT=\d+$/, root.join(".env").read)
      assert_match(/^VITE_RUBY_PORT=\d+$/, root.join(".env").read)
      refute_match(/^notesPlain=/, root.join(".env").read)
      refute_match(/^hyphen-key=/, root.join(".env").read)
      refute_match(/^EMPTY_VALUE=/, root.join(".env").read)
      assert root.join("public/codex-local-favicons/favicon.svg").exist?
      assert root.join("public/codex-local-favicons/favicon.png").exist?
      assert_equal "/public/codex-local-favicons/\n", root.join(".git/info/exclude").read
    end
  end

  test "uses the existing dotenv openrouter key when 1password resolution fails" do
    with_fake_codex_app do |root|
      File.write(root.join(".env"), "OPENROUTER_API_KEY=from-dotenv\n")

      stdout, stderr, status = run_setup_script(root)

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match "No .env values were refreshed from 1Password; preserving existing .env entries.", stdout
      assert_equal(
        [ "runner Model.refresh!" ],
        rails_log_lines(root, "rails-args.log"),
      )
      assert_equal(
        [ "OPENROUTER_API_KEY=from-dotenv", "FAL_KEY=" ],
        rails_log_lines(root, "rails-env.log"),
      )
      assert_match(/^OPENROUTER_API_KEY=from-dotenv$/, root.join(".env").read)
      assert_match(/^PORT=\d+$/, root.join(".env").read)
      assert_match(/^VITE_RUBY_PORT=\d+$/, root.join(".env").read)
    end
  end

  test "fails loudly when openrouter cannot be loaded from either 1password or dotenv" do
    with_fake_codex_app do |root|
      stdout, stderr, status = run_setup_script(root)

      refute status.success?, "expected setup script to fail when OPENROUTER_API_KEY is missing"
      assert_match "FATAL: OPENROUTER_API_KEY is missing from .env after setup.", stderr
      assert_match "will not continue without it", stderr
      assert_match "Personal/codex_local_workspace", stderr
      assert_empty rails_log_lines(root, "rails-args.log")
      assert_empty rails_log_lines(root, "rails-env.log")
      assert_match(/^PORT=\d+$/, root.join(".env").read)
      assert_match(/^VITE_RUBY_PORT=\d+$/, root.join(".env").read)
      refute_match(/^OPENROUTER_API_KEY=/, root.join(".env").read)
    end
  end

  test "preserves existing local dev port assignments across reruns" do
    with_fake_codex_app do |root|
      File.write(root.join(".env"), "OPENROUTER_API_KEY=from-dotenv\nPORT=4100\nVITE_RUBY_PORT=4136\nCUSTOM_FLAG=1\n")

      stdout, stderr, status = run_setup_script(root, "--skip-models")

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match "Configured local dev ports: Rails 4100, Vite 4136", stdout
      assert_equal(
        "OPENROUTER_API_KEY=from-dotenv\nPORT=4100\nVITE_RUBY_PORT=4136\nCUSTOM_FLAG=1\n",
        root.join(".env").read,
      )

      stdout, stderr, status = run_setup_script(root, "--skip-models")

      assert status.success?, "expected second setup script run to succeed, stderr: #{stderr}"
      assert_match "Configured local dev ports: Rails 4100, Vite 4136", stdout
      assert_equal(
        "OPENROUTER_API_KEY=from-dotenv\nPORT=4100\nVITE_RUBY_PORT=4136\nCUSTOM_FLAG=1\n",
        root.join(".env").read,
      )
    end
  end

  test "updates an existing local openrouter key when 1password resolves a newer one" do
    with_fake_codex_app do |root|
      write_fake_op(root, openrouter_api_key: "fresh-openrouter-key")
      File.write(root.join(".env"), "OPENROUTER_API_KEY=stale-key\nPORT=4100\nVITE_RUBY_PORT=4136\n")

      stdout, stderr, status = run_setup_script(root)

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match "Setup complete.", stdout
      assert_equal(
        "OPENROUTER_API_KEY=fresh-openrouter-key\nPORT=4100\nVITE_RUBY_PORT=4136\n",
        root.join(".env").read,
      )
    end
  end

  test "ignores non-env-style field labels from the 1password workspace item" do
    with_fake_codex_app do |root|
      write_fake_op(
        root,
        fields: {
          "OPENROUTER_API_KEY" => "test-openrouter-key",
          "UPPERCASE_OK" => "expected",
          "lowercase_key" => "ignored-lowercase",
          "contains-dash" => "ignored-dash",
          "EMPTY_VALUE" => ""
        },
      )

      stdout, stderr, status = run_setup_script(root, "--skip-models")

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match "Updated .env values from 1Password: OPENROUTER_API_KEY,UPPERCASE_OK", stdout
      assert_match(/^OPENROUTER_API_KEY=test-openrouter-key$/, root.join(".env").read)
      assert_match(/^UPPERCASE_OK=expected$/, root.join(".env").read)
      refute_match(/^lowercase_key=/, root.join(".env").read)
      refute_match(/^contains-dash=/, root.join(".env").read)
      refute_match(/^EMPTY_VALUE=/, root.join(".env").read)
    end
  end

  test "probes forward when the preferred port pair is occupied" do
    with_fake_codex_app do |root|
      preferred = Setup::LocalDevPorts.preferred_ports_for_root(root.to_s)
      File.write(root.join(".env"), "OPENROUTER_API_KEY=from-dotenv\n")

      stdout, stderr, status = run_setup_script(
        root,
        "--skip-models",
        env: {
          Setup::LocalDevPorts::OCCUPIED_PORTS_ENV => [
            preferred.fetch("PORT"),
            preferred.fetch("VITE_RUBY_PORT")
          ].join(",")
        },
      )

      assert status.success?, "expected setup script to succeed, stderr: #{stderr}"
      assert_match(
        "Configured local dev ports: Rails #{preferred.fetch("PORT") + 1}, Vite #{preferred.fetch("VITE_RUBY_PORT") + 1}",
        stdout,
      )

      assert_match(/^OPENROUTER_API_KEY=from-dotenv$/, root.join(".env").read)
      assert_match(/^PORT=#{preferred.fetch("PORT") + 1}$/, root.join(".env").read)
      assert_match(/^VITE_RUBY_PORT=#{preferred.fetch("VITE_RUBY_PORT") + 1}$/, root.join(".env").read)
    end
  end

  private

  def with_fake_codex_app
    Dir.mktmpdir("codex-setup-script-test") do |tmpdir|
      root = Pathname(tmpdir)

      FileUtils.mkdir_p(root.join("bin"))
      FileUtils.mkdir_p(root.join(".kamal"))
      FileUtils.mkdir_p(root.join(".git/info"))
      FileUtils.mkdir_p(root.join("lib/setup"))
      FileUtils.mkdir_p(root.join("tmp"))
      FileUtils.mkdir_p(root.join("tool-bin"))

      copy_script_fixture(root)
      copy_helper_fixture(root)
      copy_local_dev_ports_fixture(root)
      copy_local_favicon_fixture(root)
      write_fake_rails(root)
      write_noop_command(root.join("tool-bin/bundle"))
      write_fake_git(root)
      write_noop_command(root.join("tool-bin/npm"))

      yield root
    end
  end

  def copy_script_fixture(root)
    source = Rails.root.join("bin/codex-setup-script")
    target = root.join("bin/codex-setup-script")

    FileUtils.cp(source, target)
    FileUtils.chmod(0o755, target)
  end

  def copy_helper_fixture(root)
    source = Rails.root.join("lib/setup/one_password_secret_resolver.rb")
    target = root.join("lib/setup/one_password_secret_resolver.rb")

    FileUtils.cp(source, target)
  end

  def copy_local_dev_ports_fixture(root)
    source = Rails.root.join("lib/setup/local_dev_ports.rb")
    target = root.join("lib/setup/local_dev_ports.rb")

    FileUtils.cp(source, target)
  end

  def copy_local_favicon_fixture(root)
    source = Rails.root.join("lib/setup/local_favicon.rb")
    target = root.join("lib/setup/local_favicon.rb")

    FileUtils.cp(source, target)
  end

  def write_fake_rails(root)
    path = root.join("bin/rails")

    File.write(path, <<~BASH)
      #!/usr/bin/env bash
      set -euo pipefail

      ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

      printf '%s\\n' "$*" >> "$ROOT/tmp/rails-args.log"

      if [[ "${1:-}" == "runner" ]]; then
        printf 'OPENROUTER_API_KEY=%s\\n' "${OPENROUTER_API_KEY:-}" >> "$ROOT/tmp/rails-env.log"
        printf 'FAL_KEY=%s\\n' "${FAL_KEY:-}" >> "$ROOT/tmp/rails-env.log"
      fi
    BASH

    FileUtils.chmod(0o755, path)
  end

  def write_noop_command(path)
    File.write(path, <<~BASH)
      #!/usr/bin/env bash
      exit 0
    BASH

    FileUtils.chmod(0o755, path)
  end

  def write_fake_git(root)
    path = root.join("tool-bin/git")

    File.write(path, <<~BASH)
      #!/usr/bin/env bash
      set -euo pipefail

      ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

      if [[ "${1:-}" == "rev-parse" && "${2:-}" == "--git-path" && "${3:-}" == "info/exclude" ]]; then
        mkdir -p "$ROOT/.git/info"
        printf '.git/info/exclude\\n'
        exit 0
      fi

      exit 1
    BASH

    FileUtils.chmod(0o755, path)
  end

  def write_fake_op(root, openrouter_api_key: nil, fields: nil)
    path = root.join("tool-bin/op")
    values = (fields || {}).dup
    values["OPENROUTER_API_KEY"] = openrouter_api_key if openrouter_api_key
    item_json = JSON.dump(
      {
        "fields" => values.map do |field_name, value|
          { "label" => field_name, "value" => value }
        end
      },
    )

    File.write(path, <<~BASH)
      #!/usr/bin/env bash
      set -euo pipefail

      ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
      printf '%s\\n' "$*" >> "$ROOT/tmp/op-args.log"

      if [[ "${1:-}" == "item" && "${2:-}" == "get" ]]; then
        if [[ " $* " == *" --format json "* ]]; then
          printf '%s\\n' #{item_json.inspect}
          exit 0
        fi

        exit 0
      fi

      exit 1
    BASH

    FileUtils.chmod(0o755, path)
  end

  def run_setup_script(root, *extra_args, env: {})
    env = {
      "PATH" => "#{root.join("tool-bin")}:#{ENV.fetch("PATH")}",
      "HOME" => root.to_s,
      "FAL_KEY" => nil
    }.merge(env)

    Open3.capture3(
      env,
      root.join("bin/codex-setup-script").to_s,
      "--skip-bundle",
      "--skip-node",
      "--skip-css",
      "--skip-db",
      *extra_args,
      chdir: root.to_s,
    )
  end

  def rails_log_lines(root, name)
    path = root.join("tmp", name)
    return [] unless path.exist?

    path.read.split("\n")
  end
end
