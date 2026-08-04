# frozen_string_literal: true

require 'wor/paginate'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Assumes the controller includes Wor::Paginate.
    class WorPaginateAdapter
      include Adapter

      def paginate(controller, klass, options)
        controller.send(:render_paginated, klass, options)
      end
    end
  end
end
