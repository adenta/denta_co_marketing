module Analytics
  class AhoyPruner
    DEFAULT_DAYS = 365

    def initialize(days: DEFAULT_DAYS, now: Time.current)
      @days = normalize_days(days)
      @now = now
    end

    attr_reader :days, :now

    def call
      {
        cutoff: cutoff,
        visits_deleted: prune_visits,
        events_deleted: prune_events,
      }
    end

    private

    def normalize_days(days)
      value = days.to_i
      value.positive? ? value : DEFAULT_DAYS
    end

    def cutoff
      days.days.ago.beginning_of_day
    end

    def prune_visits
      Ahoy::Visit.where("started_at < ?", cutoff).delete_all
    end

    def prune_events
      Ahoy::Event.where("time < ?", cutoff).delete_all
    end
  end
end
