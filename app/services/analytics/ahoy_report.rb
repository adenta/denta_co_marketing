module Analytics
  class AhoyReport
    DEFAULT_DAYS = 7
    TOP_LIMIT = 5
    DIRECT_LABEL = "(direct)".freeze
    UNKNOWN_LABEL = "(unknown)".freeze

    def initialize(days: DEFAULT_DAYS, now: Time.current)
      @days = normalize_days(days)
      @now = now
    end

    attr_reader :days, :now

    def summary
      visits = visits_scope.to_a
      events = events_scope.to_a

      {
        days: days,
        starts_at: window_start,
        ends_at: now,
        visits: visits.count,
        unique_visitors: visits.filter_map(&:visitor_token).uniq.count,
        events: events.count,
        page_views: view_events(events).count,
        top_pages: top_counts(view_events(events).map { |event| property(event, "page") }, fallback: UNKNOWN_LABEL),
        top_referrers: top_counts(visits.map(&:referring_domain), fallback: DIRECT_LABEL),
        top_events: top_counts(custom_events(events).map(&:name), fallback: UNKNOWN_LABEL),
      }
    end

    def timeline
      rows = timeline_days.index_with do |day|
        {
          date: day,
          visits: 0,
          views: 0,
          custom_events: 0,
          events: 0,
        }
      end

      visits_scope.find_each do |visit|
        day = visit.started_at&.to_date
        next unless rows.key?(day)

        rows[day][:visits] += 1
      end

      events_scope.find_each do |event|
        day = event.time&.to_date
        next unless rows.key?(day)

        rows[day][:events] += 1
        if event.name == "$view"
          rows[day][:views] += 1
        else
          rows[day][:custom_events] += 1
        end
      end

      timeline_days.map { |day| rows.fetch(day) }
    end

    private

    def normalize_days(days)
      value = days.to_i
      value.positive? ? value : DEFAULT_DAYS
    end

    def window_start
      days.days.ago.beginning_of_day
    end

    def timeline_days
      (window_start.to_date..now.to_date).to_a
    end

    def visits_scope
      Ahoy::Visit.where(started_at: window_start..now)
    end

    def events_scope
      Ahoy::Event.where(time: window_start..now)
    end

    def view_events(events)
      events.select { |event| event.name == "$view" }
    end

    def custom_events(events)
      events.reject { |event| event.name == "$view" }
    end

    def property(event, key)
      properties = event.properties.is_a?(Hash) ? event.properties : {}
      properties[key].presence
    end

    def top_counts(values, fallback:)
      values
        .map { |value| value.presence || fallback }
        .tally
        .sort_by { |value, count| [ -count, value ] }
        .first(TOP_LIMIT)
        .map { |value, count| { value: value, count: count } }
    end
  end
end
