module Tools
  class SpinSlotMachine < RubyLLM::Tool
    REELS = [
      "cherry",
      "lemon",
      "bar",
      "bell",
      "seven",
      "horseshoe"
    ].freeze
    PAYOUTS_CENTS = [ -250, -200, -150, -100, -50, 0, 25, 50, 100, 150, 200, 250 ].freeze

    description "Spin a mock slot machine once and return the updated running total."

    params do
      integer :current_total_cents, required: false, description: "Current winnings total in cents"
      integer :spin_count, required: false, description: "Number of spins already used"
      integer :target_cents, required: false, description: "Target winnings in cents"
      integer :max_spins, required: false, description: "Maximum allowed spins"
    end

    def execute(current_total_cents: 0, spin_count: 0, target_cents: 10_000, max_spins: 12)
      next_spin_count = spin_count.to_i + 1
      delta_cents = PAYOUTS_CENTS.sample
      new_total_cents = current_total_cents.to_i + delta_cents
      reels = Array.new(3) { REELS.sample }
      reached_target = new_total_cents >= target_cents.to_i
      exhausted_spins = next_spin_count >= max_spins.to_i
      should_continue = !reached_target && !exhausted_spins

      {
        spin_count: next_spin_count,
        max_spins: max_spins.to_i,
        spins_remaining: [ max_spins.to_i - next_spin_count, 0 ].max,
        target_cents: target_cents.to_i,
        delta_cents: delta_cents,
        new_total_cents: new_total_cents,
        reels: reels,
        should_continue: should_continue,
        stop_reason: stop_reason(reached_target, exhausted_spins)
      }
    end

    private

    def stop_reason(reached_target, exhausted_spins)
      return "target_reached" if reached_target
      return "max_spins_reached" if exhausted_spins

      nil
    end
  end
end
