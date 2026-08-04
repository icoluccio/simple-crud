# frozen_string_literal: true

require 'cancancan'
require_relative 'adapter'

module SimpleCrud
  module Authorization
    # A single Ability class governs everything, so #policy_defined? can
    # only confirm one is configured, not that it covers this model.
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
