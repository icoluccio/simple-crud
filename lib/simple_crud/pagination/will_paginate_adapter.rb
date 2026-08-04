# frozen_string_literal: true

require 'will_paginate'
require 'will_paginate/active_record'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for will_paginate (https://github.com/mislav/will_paginate).
    # Renders a plain array, unlike wor-paginate's {page:, count:, ...}
    # envelope. Uses #paginate rather than #page, since Kaminari also
    # defines #page and the two would clobber each other if both are loaded.
    class WillPaginateAdapter
      include Adapter

      def paginate(controller, klass, options)
        page = controller.params[:page] || 1
        per_page = controller.params[:per_page] || WillPaginate.per_page
        records = klass.paginate(page: page, per_page: per_page)
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
