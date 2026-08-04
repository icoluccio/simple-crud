# frozen_string_literal: true

require 'will_paginate'
require 'will_paginate/active_record'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for will_paginate (https://github.com/mislav/will_paginate).
    # Uses #paginate rather than #page, since Kaminari also defines #page.
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
