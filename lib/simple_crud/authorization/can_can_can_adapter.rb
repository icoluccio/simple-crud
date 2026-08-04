# frozen_string_literal: true

require 'cancancan'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Adapter for CanCanCan (https://github.com/CanCanCommunity/cancancan).
    # Assumes the consuming controller includes CanCan::ControllerAdditions
    # (loaded automatically by cancancan in Rails controllers) so #authorize!
    # is available.
    #
    # Unlike Pundit/Action Policy, CanCanCan has no per-model policy classes:
    # a single Ability class governs every model. #policy_defined? can
    # therefore only check that some Ability is configured at all, not that
    # it actually covers the given model.
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
