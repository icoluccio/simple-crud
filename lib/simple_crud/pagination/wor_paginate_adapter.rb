# frozen_string_literal: true

require 'wor/paginate'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Assumes the controller includes Wor::Paginate.
    class WorPaginateAdapter
      include Adapter

      def paginate(controller, relation, options)
        controller.send(:render_paginated, relation, options)
      end

      def paginated_records(controller, relation, options)
        adapter = controller.send(:find_adapter_for_content, relation, options)
        adapter.paginated_content
      end
    end
  end
end
