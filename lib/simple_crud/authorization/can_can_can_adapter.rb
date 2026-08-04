# frozen_string_literal: true

require 'cancancan'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Adapter for CanCanCan (https://github.com/CanCanCommunity/cancancan).
    # Unlike Pundit/Action Policy, CanCanCan has no per-model policy classes:
    # a single Ability class governs everything, so #policy_defined? can only
    # check that some Ability is configured, not that it covers this model.
    class CanCanCanAdapter
      include Adapter

      def authorize(controller, record)
        controller.send(:authorize!, controller.action_name.to_sym, record)
      end

      def policy_defined?(_model_class)
        Kernel.const_defined?('Ability')
      end
    end
  end
end
