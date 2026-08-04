# frozen_string_literal: true

module SimpleCrud
  module Authorization
    # Translates simple_crud's authorization calls into a specific
    # authorization library's API. Implement both methods and pass an
    # instance to SimpleCrud.configure to plug in a library other than
    # Pundit (the default, see PunditAdapter).
    module Adapter
      # Called from inside a generated CRUD action to check whether
      # +controller+'s current user may act on +record+. Should raise (or
      # otherwise halt the request) when not authorized; simple_crud doesn't
      # rescue anything itself, so raise whatever your app's rescue_from
      # handlers already expect (e.g. Pundit::NotAuthorizedError).
      def authorize(controller, record)
        raise NotImplementedError
      end

      # Called once, when simple_crud_for is invoked, to fail fast if the
      # given model has no authorization rules defined at all.
      def policy_defined?(model_class)
        raise NotImplementedError
      end
    end
  end
end
