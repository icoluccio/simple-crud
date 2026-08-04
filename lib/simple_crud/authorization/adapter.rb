# frozen_string_literal: true

module SimpleCrud
  module Authorization
    # Implement both methods and pass an instance to SimpleCrud.configure to
    # plug in a library other than Pundit (the default, see PunditAdapter).
    module Adapter
      # Raise (e.g. Pundit::NotAuthorizedError) when +controller+'s current
      # user may not act on +record+; simple_crud doesn't rescue anything itself.
      def authorize(controller, record)
        raise NotImplementedError
      end

      # Called once, when simple_crud_for is invoked, to fail fast if
      # +model_class+ has no authorization rules defined at all.
      def policy_defined?(model_class)
        raise NotImplementedError
      end
    end
  end
end
