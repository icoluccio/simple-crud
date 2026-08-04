# frozen_string_literal: true

require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Default authorization adapter, matching Pundit's own conventions:
    # `#{Model}Policy` classes with `user`/`record` initializers, checked via
    # the controller's own `authorize` (from Pundit::Authorization).
    class PunditAdapter
      include Adapter

      def authorize(controller, record)
        # Pundit::Authorization#authorize is protected, so it can only be
        # called from inside the controller itself; bounce through send.
        controller.send(:authorize, record)
      end

      def policy_defined?(model_class)
        Kernel.const_defined?("#{model_class}Policy")
      end
    end
  end
end
