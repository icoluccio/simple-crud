# frozen_string_literal: true

require 'kaminari'
require 'kaminari/activerecord'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # https://github.com/kaminari/kaminari
    class KaminariAdapter
      include Adapter

      def paginate(controller, relation, options)
        records = paginated_records(controller, relation, options)
        controller.render({ json: records }.merge(options))
      end

      # Manual page scope: will_paginate shadows Relation#page when both load.
      def paginated_records(controller, relation, _options)
        page = [controller.params[:page].to_i, 1].max
        per_page = page_size(controller)

        relation.limit(per_page).offset(per_page * (page - 1)).extending do
          include Kaminari::ActiveRecordRelationMethods
          include Kaminari::PageScopeMethods
        end
      end

      private

      # Params arrive as strings: coerce before arithmetic or "5" * 2 == "55".
      def page_size(controller)
        size = (controller.params[:per_page] || Kaminari.config.default_per_page).to_i
        size = [size, 1].max
        size = [size, Kaminari.config.max_per_page].min if Kaminari.config.max_per_page
        size
      end
    end
  end
end
