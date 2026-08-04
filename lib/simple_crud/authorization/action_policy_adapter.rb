# frozen_string_literal: true

require 'action_policy'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Adapter for Action Policy (https://github.com/palkan/action_policy).
    # Assumes the controller includes ActionPolicy::Controller (not the bare
    # Behaviour), which defaults the rule to the current action name.
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
