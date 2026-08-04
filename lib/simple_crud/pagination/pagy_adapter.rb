# frozen_string_literal: true

require 'pagy'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for Pagy (https://github.com/ddnexus/pagy). Assumes the
    # consuming controller includes Pagy::Method (Pagy's own controller
    # mixin). Renders a plain array (no wrapping envelope, unlike
    # wor-paginate's {page:, count:, ...}).
    class PagyAdapter
      include Adapter

      def paginate(controller, klass, options)
        # Pagy only honors a client-supplied `limit` param once a max is
        # set (a deliberate safety default); without it every page uses the
        # fixed default limit (20) regardless of what the client asks for.
        # The option was renamed client_max_limit -> max_limit in 43.5.0;
        # pass both so this works across that split (43.4.x is still what
        # Ruby < 3.3 resolves to, since 43.5.0+ requires Ruby >= 3.3).
        _pagy, records = controller.send(:pagy, klass.all, max_limit: 100, client_max_limit: 100)
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
