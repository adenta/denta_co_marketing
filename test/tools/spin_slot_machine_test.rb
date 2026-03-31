require "test_helper"

module Tools
  class SpinSlotMachineTest < ActiveSupport::TestCase
    test "returns a bounded random slot result payload" do
      result = Tools::SpinSlotMachine.new.execute(
        current_total_cents: 500,
        spin_count: 2,
        target_cents: 10_000,
        max_spins: 12,
      )

      assert_equal 3, result[:spin_count]
      assert_equal 12, result[:max_spins]
      assert_equal 9, result[:spins_remaining]
      assert_equal 10_000, result[:target_cents]
      assert_includes [ -250, -200, -150, -100, -50, 0, 25, 50, 100, 150, 200, 250 ], result[:delta_cents]
      assert_equal 500 + result[:delta_cents], result[:new_total_cents]
      assert_equal 3, result[:reels].length
      assert result[:reels].all? { |symbol| Tools::SpinSlotMachine::REELS.include?(symbol) }
      assert_includes [ true, false ], result[:should_continue]
      assert_nil result[:stop_reason]
    end

    test "stops once max spins are reached" do
      result = Tools::SpinSlotMachine.new.execute(
        current_total_cents: 700,
        spin_count: 11,
        target_cents: 10_000,
        max_spins: 12,
      )

      assert_equal 12, result[:spin_count]
      assert_equal 0, result[:spins_remaining]
      assert_equal false, result[:should_continue]
      assert_equal "max_spins_reached", result[:stop_reason]
      assert_operator result[:new_total_cents], :<=, 950
    end
  end
end
