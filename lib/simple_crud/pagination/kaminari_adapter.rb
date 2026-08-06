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

      # Kaminari only defines `page` on the model class, not on relations, and
      # will_paginate shadows `Relation#page` when both gems are loaded. Build
      # the page scope explicitly so scoped relations paginate correctly.
      def paginated_records(controller, relation, _options)
        page = controller.params[:page] || 1
        per_page = controller.params[:per_page] || Kaminari.config.default_per_page
        offset = per_page * (page.to_i.clamp(1, Float::INFINITY) - 1)
        relation.limit(per_page).offset(offset).extending do
          include Kaminari::ActiveRecordRelationMethods
          include Kaminari::PageScopeMethods
        end
      end
    end
  end
end
