namespace :analytics do
  namespace :ahoy do
    # Blazer already ships operational tasks we should use directly:
    # - rake blazer:run_checks SCHEDULE="1 hour"
    # - rake blazer:send_failing_checks
    # - rake blazer:archive_queries

    desc "Print an Ahoy summary for the last N days (default: 7)"
    task :summary, [:days] => :environment do |_, args|
      report = Analytics::AhoyReport.new(days: task_days(args[:days]))
      summary = report.summary

      puts "Ahoy summary: last #{summary.fetch(:days)} day(s)"
      puts "Window: #{summary.fetch(:starts_at).iso8601} to #{summary.fetch(:ends_at).iso8601}"
      puts "Visits: #{summary.fetch(:visits)}"
      puts "Unique visitors: #{summary.fetch(:unique_visitors)}"
      puts "Events: #{summary.fetch(:events)}"
      puts "Page views: #{summary.fetch(:page_views)}"
      print_ranked_section("Top pages", summary.fetch(:top_pages))
      print_ranked_section("Top referrers", summary.fetch(:top_referrers))
      print_ranked_section("Top custom events", summary.fetch(:top_events))
    end

    desc "Print day-by-day Ahoy visits and events for the last N days (default: 7)"
    task :timeline, [:days] => :environment do |_, args|
      report = Analytics::AhoyReport.new(days: task_days(args[:days]))

      puts "Ahoy timeline: last #{report.days} day(s)"
      puts format("%-12s %8s %8s %8s %14s", "Date", "Visits", "Events", "Views", "Custom events")
      report.timeline.each do |row|
        puts format(
          "%-12s %8d %8d %8d %14d",
          row.fetch(:date).iso8601,
          row.fetch(:visits),
          row.fetch(:events),
          row.fetch(:views),
          row.fetch(:custom_events),
        )
      end
    end

    desc "Delete Ahoy visits and events older than N days (default: 365)"
    task :prune, [:days] => :environment do |_, args|
      result = Analytics::AhoyPruner.new(days: task_days(args[:days], default: 365)).call

      puts "Pruned Ahoy data older than #{result.fetch(:cutoff).iso8601}"
      puts "Visits deleted: #{result.fetch(:visits_deleted)}"
      puts "Events deleted: #{result.fetch(:events_deleted)}"
    end

    def task_days(value, default: 7)
      value.presence&.to_i&.positive? ? value.to_i : default
    end

    def print_ranked_section(title, rows)
      puts "#{title}:"
      if rows.any?
        rows.each_with_index do |row, index|
          puts format("  %d. %s (%d)", index + 1, row.fetch(:value), row.fetch(:count))
        end
      else
        puts "  none"
      end
    end
  end
end
