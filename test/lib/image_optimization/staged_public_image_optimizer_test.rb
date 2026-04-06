# frozen_string_literal: true

require "fileutils"
require "open3"
require "stringio"
require "test_helper"
require "tmpdir"
require "vips"

class ImageOptimization::StagedPublicImageOptimizerTest < ActiveSupport::TestCase
  test "optimizes and restages staged public jpeg files" do
    with_git_repo do |root|
      path = root.join("public/social.jpeg")
      write_unoptimized_jpeg(path)
      before_bytes = path.size

      git!(root, "add", "--", path.relative_path_from(root).to_s)

      stdout = StringIO.new
      stderr = StringIO.new

      success = ImageOptimization::StagedPublicImageOptimizer.new(
        repo_root: root,
        stdout: stdout,
        stderr: stderr,
      ).run

      assert success
      assert_empty stderr.string
      assert_operator path.size, :<, before_bytes
      assert_includes stdout.string, "optimized public/social.jpeg"
      assert_equal [ "public/social.jpeg" ], git_lines(root, "diff", "--cached", "--name-only")
    end
  end

  test "fails when a staged public image also has unstaged changes" do
    with_git_repo do |root|
      path = root.join("public/social.jpeg")
      write_unoptimized_jpeg(path)
      git!(root, "add", "--", path.relative_path_from(root).to_s)
      git!(root, "commit", "-m", "Add social image")

      write_unoptimized_jpeg(path)
      result = ImageOptimization::PublicImageOptimizer.optimize(path)
      assert result.changed?
      git!(root, "add", "--", path.relative_path_from(root).to_s)
      File.open(path, "ab") { |file| file.write("dirty") }

      stdout = StringIO.new
      stderr = StringIO.new

      success = ImageOptimization::StagedPublicImageOptimizer.new(
        repo_root: root,
        stdout: stdout,
        stderr: stderr,
      ).run

      refute success
      assert_empty stdout.string
      assert_includes stderr.string, "staged public images also have unstaged changes"
      assert_includes stderr.string, "public/social.jpeg"
    end
  end

  test "ignores staged svg files" do
    with_git_repo do |root|
      path = root.join("public/icon.svg")
      FileUtils.mkdir_p(path.dirname)
      FileUtils.cp(Rails.root.join("public/icon.svg"), path)
      git!(root, "add", "--", path.relative_path_from(root).to_s)

      stdout = StringIO.new
      stderr = StringIO.new

      success = ImageOptimization::StagedPublicImageOptimizer.new(
        repo_root: root,
        stdout: stdout,
        stderr: stderr,
      ).run

      assert success
      assert_empty stderr.string
      assert_equal "optimize-staged-images: no staged public raster images\n", stdout.string
    end
  end

  test "handles staged png files" do
    with_git_repo do |root|
      path = root.join("public/icon.png")
      FileUtils.mkdir_p(path.dirname)
      FileUtils.cp(Rails.root.join("public/icon.png"), path)
      git!(root, "add", "--", path.relative_path_from(root).to_s)

      stdout = StringIO.new
      stderr = StringIO.new

      success = ImageOptimization::StagedPublicImageOptimizer.new(
        repo_root: root,
        stdout: stdout,
        stderr: stderr,
      ).run

      assert success
      assert_empty stderr.string
      assert_match(/optimize-staged-images: (?:optimized|kept) public\/icon\.png/, stdout.string)
    end
  end

  private

  def with_git_repo
    Dir.mktmpdir("staged-public-image-optimizer-test") do |tmpdir|
      root = Pathname(tmpdir)
      git!(root, "init")
      git!(root, "config", "user.name", "Codex")
      git!(root, "config", "user.email", "codex@example.com")
      yield root
    end
  end

  def git!(root, *args)
    stdout, stderr, status = Open3.capture3("git", *args, chdir: root.to_s)
    assert status.success?, "git #{args.join(' ')} failed: #{stdout}\n#{stderr}"
  end

  def git_lines(root, *args)
    stdout, stderr, status = Open3.capture3("git", *args, chdir: root.to_s)
    assert status.success?, "git #{args.join(' ')} failed: #{stdout}\n#{stderr}"

    stdout.lines.map(&:chomp)
  end

  def write_unoptimized_jpeg(path)
    FileUtils.mkdir_p(path.dirname)
    image = Vips::Image.new_from_file(Rails.root.join("public/andrew-denta-2026.jpeg").to_s, access: :sequential)
    image.jpegsave(path.to_s, Q: 100, strip: false, optimize_coding: false, interlace: false)
  end
end
