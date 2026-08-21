# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Request params and format helpers shared by every action example.
      module Requests
        # :unprocessable_entity was renamed :unprocessable_content in Rack 3.1.
        # Resolve the current Rack's canonical symbol for 422.
        def unprocessable_status
          Rack::Utils::SYMBOL_TO_STATUS_CODE.invert[422]
        end

        def request_format(action)
          check_html(action) ? :html : :json
        end

        # Extra params (e.g. a parent slug) added to every request, for nested
        # resources like /projects/:project_slug/tasks.
        def route_params
          resolve(setting(:route_params))
        end

        def with_route_params(attrs)
          route_params.merge(attrs)
        end

        # The params that identify a record for the given action, using the
        # configured finder_key when the action has a custom finder.
        def record_param(action, record, not_found: false)
          key = check_finder(action) ? finder_key : :id
          value = not_found ? "nonexistent-#{key}" : record.public_send(key)
          { key => value }
        end

        # Wraps a request body under the model's strong-params key when
        # params_key is configured (nested strong params), else passes it flat.
        def body_params(attrs)
          key = params_key
          key ? { key => attrs } : attrs
        end
      end
    end
  end
end
