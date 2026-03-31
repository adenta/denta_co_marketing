class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :chatable, polymorphic: true, optional: true

  acts_as_chat messages_foreign_key: :chat_id

  before_validation :assign_default_agent_type

  validates :agent_type, presence: true
  validate :agent_type_must_resolve
  validate :chatable_compatible_with_agent

  def self.default_agent_type
    AssistantAgent.name
  end

  def self.available_agent_types
    Dir.glob(Rails.root.join("app/agents/**/*_agent.rb")).sort.filter_map do |path|
      agent_type = path
        .delete_prefix("#{Rails.root.join("app/agents")}/")
        .delete_suffix(".rb")
        .camelize
      klass = resolve_agent_class(agent_type)
      next unless klass&.chat_model == self

      klass.name
    end
  end

  def self.available_agents
    available_agent_types.filter_map do |agent_type|
      klass = resolve_agent_class(agent_type)
      next unless klass

      {
        agent_type: klass.name,
        label: klass.respond_to?(:list_name) ? klass.list_name : klass.name.delete_suffix("Agent").titleize
      }
    end
  end

  def self.resolve_agent_class(agent_type)
    return nil if agent_type.blank?

    klass = agent_type.safe_constantize
    return nil unless klass.is_a?(Class) && klass < RubyLLM::Agent

    klass
  end

  def agent_class
    self.class.resolve_agent_class(agent_type)
  end

  def agent
    klass = agent_class
    raise ArgumentError, "Invalid agent_type: #{agent_type}" unless klass

    klass.new(chat: self, persist_instructions: false)
  end

  def display_name
    agent_metadata(:display_name) || "Chat"
  end

  def linked_resource
    agent_metadata(:linked_resource)
  end

  private

  def assign_default_agent_type
    self.agent_type = self.class.default_agent_type if agent_type.blank?
  end

  def agent_type_must_resolve
    return if agent_class

    errors.add(:agent_type, "is not a valid RubyLLM agent")
  end

  def chatable_compatible_with_agent
    return unless agent_class

    agent_class.validate_chatable!(self)
  rescue ArgumentError => error
    errors.add(:chatable, error.message)
  end

  def agent_metadata(method_name)
    return unless agent_class&.respond_to?(method_name)

    agent_class.public_send(method_name, self)
  end
end
