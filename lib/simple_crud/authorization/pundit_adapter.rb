# frozen_string_literal: true

require_relative 'adapter'

module SimpleCrud
  module Authorization
    # Default authorization adapter: standard Pundit `#{Model}Policy` classes.
    class PunditAdapter
      include Adapter

      def authorize(controller, record)
        # Pundit::Authorization#authorize is protected, hence send.
        controller.send(:authorize, record)
      end

      def policy_defined?(model_class)
        Kernel.const_defined?("#{model_class}Policy")
      end
    end
  end
end
