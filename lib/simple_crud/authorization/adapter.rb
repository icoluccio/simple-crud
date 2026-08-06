# frozen_string_literal: true

module SimpleCrud
  module Authorization
    # Implement to plug in an authorization library other than Pundit
    # (the default, see PunditAdapter).
    module Adapter
      # Raise when +controller+'s current user may not act on +record+.
      def authorize(controller, record)
        raise NotImplementedError
      end

      # Called once, when simple_crud_for is invoked, to fail fast if
      # +model_class+ has no authorization configured.
      def policy_defined?(model_class)
        raise NotImplementedError
      end

      # Called when rendering :index with authorize: true. Must return the
      # relation the current user is allowed to list. Defaults to the full
      # relation so no scoping dependency is required.
      def policy_scope(_controller, model_class)
        model_class.all
      end
    end
  end
end
