require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
# require 'active_support/core_ext/class/attribute_accessors'

module SolidState
  extend ActiveSupport::Concern
  class InvalidTransitionError < ArgumentError; end

  STATE_ATTRIBUTE = :state.freeze

  module ClassMethods
    def states(*list, &block)
      list = list.collect(&:to_s)

      raise "states for #{self.name} class have already been set! To get list of possible states, call #{name}.possible_states" if self.respond_to?(:possible_states)
      raise "This is not a list of names" unless list.first.respond_to?(:downcase)

      class_attribute :possible_states
      class_attribute :state_transitions

      self.possible_states = list
      self.state_transitions = {}

      if respond_to?(:validates_inclusion_of)
        validates_inclusion_of STATE_ATTRIBUTE, in: list
      end

      scope :with_state, lambda { |state|
        return query if state.blank?
        where(STATE_ATTRIBUTE => state)
      } if respond_to?(:scope)

      list.each do |s|
        scope(s, lambda { where(STATE_ATTRIBUTE => s) }) if respond_to?(:scope)

        define_method "#{s}?" do
          state.to_sym == s.to_sym
        end
      end

      yield if block_given?
    end

    def transitions(opts)
      validate :ensure_valid_transition if respond_to?(:validate)

      from = opts.delete(:from) or raise ":from required"
      to   = opts.delete(:to)   or raise ":to required"
      to   = [to] unless to.is_a?(Array)

      # puts "From #{from} to #{to.join(' or ')}"
      to.each do |dest|
        self.state_transitions[from.to_sym] ||= []
        self.state_transitions[from.to_sym].push(dest.to_sym)

        define_method("#{dest}!") do
          unless set_state(dest.to_sym)
            raise InvalidTransitionError.new("Cannot transition from #{state} to #{dest}")
          end

          if !respond_to?(:valid?) or (valid? && save)
            send("once_#{dest}", from) if respond_to?("once_#{dest}")
            send("once_not_#{from}", dest) if respond_to?("once_not_#{from}")
            true
          else
            false
          end
        end
      end
    end
  end

  def set_state!(new_state)
    raise InvalidTransitionError.new("Cannot transition from #{state} to #{dest}") unless can_transition_to?(new_state)
    self.state = new_state
  end

  def set_state(new_state)
    set_state!(new_state) rescue false
  end

  def update_state(new_state)
    save if set_state(new_state)
  end if respond_to?(:_validators)

  def update_state!(new_state)
    save! if set_state!(new_state)
  end if respond_to?(:_validators)

  private

  def ensure_valid_transition
    if send("#{STATE_ATTRIBUTE}_changed?") and !can_transition_to?(state)
      errors.add(STATE_ATTRIBUTE, "can't transition from current state to #{state}")
    end
  end

  def can_transition_to?(new_state)
    return true if state.to_sym == new_state.to_sym

    possible = self.class.state_transitions[state.to_sym] || []
    possible.include?(new_state.to_sym)
  end

end
