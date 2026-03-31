require "test_helper"

class FlashBlueprintTest < ActiveSupport::TestCase
  test "serializes supported toast keys from flash" do
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = "Signed in."
    flash[:alert] = "Something went wrong."

    serialized = FlashBlueprint.render_as_hash(flash).compact

    assert_equal({ notice: "Signed in.", alert: "Something went wrong." }, serialized)
  end

  test "does not serialize unsupported flash keys" do
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:timedout] = true

    serialized = FlashBlueprint.render_as_hash(flash).compact

    refute_includes serialized.keys, :timedout
  end
end
