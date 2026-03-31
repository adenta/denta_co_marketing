class MessageBlueprint < Blueprinter::Base
  identifier :id

  field :role do |message|
    message.role.to_s
  end

  field :parts do |message|
    UiMessagePartsBuilder.build(message)
  end
end
