# frozen_string_literal: true

require 'action_policy'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Assumes ActionPolicy::Controller (not the bare Behaviour) is included,
    # which defaults the rule to the current action name.
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
