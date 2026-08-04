# frozen_string_literal: true

require 'pagy'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for Pagy (https://github.com/ddnexus/pagy). Assumes the
    # controller includes Pagy::Method. Renders a plain array, unlike
    # wor-paginate's {page:, count:, ...} envelope.
    class PagyAdapter
      include Adapter

      def paginate(controller, klass, options)
        # Pass both key names: 43.5.0 renamed client_max_limit -> max_limit,
        # and Ruby < 3.3 resolves to the pre-rename 43.4.x.
        _pagy, records = controller.send(:pagy, klass.all, max_limit: 100, client_max_limit: 100)
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
