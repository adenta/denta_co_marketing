# frozen_string_literal: true

require "open3"
require "pathname"
require_relative "public_image_optimizer"

module ImageOptimization
  class StagedPublicImageOptimizer
    def initialize(repo_root: Pathname.pwd, stdout: $stdout, stderr: $stderr)
      @repo_root = Pathname(repo_root).expand_path
      @stdout = stdout
      @stderr = stderr
    end

    def run
      target_files = staged_public_image_files

      if target_files.empty?
        stdout.puts "optimize-staged-images: no staged public raster images"
        return true
      end

      dirty_files = unstaged_changes_for(target_files)
      if dirty_files.any?
        stderr.puts "optimize-staged-images: staged public images also have unstaged changes:"
        dirty_files.each { |path| stderr.puts "  #{path}" }
        stderr.puts "Stage or stash those changes before committing so image optimization can safely restage files."
        return false
      end

      changed_files = []

      target_files.each do |path|
        result = PublicImageOptimizer.optimize(repo_root.join(path))

        if result.changed?
          stdout.puts "optimize-staged-images: optimized #{path} (#{result.before_bytes} -> #{result.after_bytes} bytes)"
          changed_files << path
        else
          stdout.puts "optimize-staged-images: kept #{path} at #{result.before_bytes} bytes"
        end
      end

      git!(*%w[add --], *changed_files) if changed_files.any?
      true
    end

    private

    attr_reader :repo_root, :stdout, :stderr

    def staged_public_image_files
      capture!("git", "diff", "--cached", "--name-only", "--diff-filter=ACMR").select do |path|
        public_path = repo_root.join(path)
        path.start_with?("public/") &&
          public_path.file? &&
          PublicImageOptimizer.optimizable_extension?(public_path)
      end
    end

    def unstaged_changes_for(paths)
      return [] if paths.empty?

      capture!("git", "diff", "--name-only", "--", *paths)
    end

    def capture!(*command)
      output, status = Open3.capture2e(*command, chdir: repo_root.to_s)
      raise "Command failed: #{command.join(' ')}\n#{output}" unless status.success?

      output.lines.map(&:chomp)
    end

    def git!(*args)
      success = system("git", *args, chdir: repo_root.to_s)
      raise "Command failed: git #{args.join(' ')}" unless success
    end
  end
end
