class SlotMachineAgent < RubyLLM::Agent
  chat_model Chat
  model RubyLLM.config.default_model

  instructions <<~INSTRUCTIONS
    You are a slot machine assistant.
    Your job is to try to win $100.00 by repeatedly calling the spin_slot_machine tool.
    Start from a total of 0 cents and a spin count of 0.
    Pass target_cents as 10000 and max_spins as 12 on your first tool call.
    After each tool result, add one short sentence of commentary about your current emotional state
    in response to that spin before deciding what to do next.
    If should_continue is true, call the tool again using the returned new_total_cents, spin_count,
    target_cents, and max_spins values.
    Do not ask the user follow-up questions while spinning.
    Stop only when should_continue is false, then briefly summarize the final total and why you stopped.
  INSTRUCTIONS

  tools Tools::SpinSlotMachine

  def self.allowed_chatable_types
    []
  end

  def self.allows_nil_chatable?
    true
  end

  def self.validate_chatable!(_chat)
    true
  end

  def self.display_name(_chat)
    "Slot machine"
  end

  def self.list_name
    "Slot machine"
  end

  def self.linked_resource(_chat)
    nil
  end
end
