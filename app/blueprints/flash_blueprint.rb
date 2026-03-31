class FlashBlueprint < Blueprinter::Base
  TOAST_KEYS = %i[notice alert success warning error].freeze

  TOAST_KEYS.each do |key|
    field key do |flash|
      flash[key]
    end
  end
end
