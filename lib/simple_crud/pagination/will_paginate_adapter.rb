# frozen_string_literal: true

require 'will_paginate'
require 'will_paginate/active_record'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for will_paginate (https://github.com/mislav/will_paginate).
    # Uses #paginate, not #page (also defined by Kaminari).
    class WillPaginateAdapter
      include Adapter

      def paginate(controller, relation, options)
        records = paginated_records(controller, relation, options)
        controller.render({ json: records }.merge(options))
      end

      def paginated_records(controller, relation, _options)
        page = controller.params[:page] || 1
        per_page = controller.params[:per_page] || WillPaginate.per_page
        relation.paginate(page: page, per_page: per_page)
      end
    end
  end
end
