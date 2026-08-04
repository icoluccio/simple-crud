# frozen_string_literal: true

require 'action_policy'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Adapter for Action Policy (https://github.com/palkan/action_policy).
    # Assumes the consuming controller includes ActionPolicy::Controller
    # (not the bare ActionPolicy::Behaviour) -- that's what makes the rule
    # passed to #authorize! default to the current action name, matching
    # how Pundit's own #authorize infers it. Policies follow the same
    # "#{Model}Policy" naming convention as Pundit.
    class ActionPolicyAdapter
      include Adapter

      def authorize(controller, record)
        controller.send(:authorize!, record)
      end

      def policy_defined?(model_class)
        Kernel.const_defined?("#{model_class}Policy")
      end
    end
  end
end
