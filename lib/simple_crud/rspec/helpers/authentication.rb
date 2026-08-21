# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Current/other users, signing requests in and the owner association
      # attributed to the current user.
      module Authentication
        def current_user
          @current_user ||= instance_exec(&setting(:current_user))
        end

        def other_user
          @other_user ||= instance_exec(&setting(:other_user))
        end

        def authenticate_request
          instance_exec(&setting(:authenticate))
        end

        def owner_foreign_key
          :"#{owner_association}_id"
        end

        # The owner association attributed to current_user, if the model has one.
        def owner_params
          owner_association ? { owner_foreign_key => current_user.id } : {}
        end
      end
    end
  end
end
