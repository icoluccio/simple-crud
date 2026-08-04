# frozen_string_literal: true

require 'kaminari'
require 'kaminari/activerecord'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Adapter for Kaminari (https://github.com/kaminari/kaminari). Renders a
    # plain array, unlike wor-paginate's {page:, count:, ...} envelope.
    class KaminariAdapter
      include Adapter

      def paginate(controller, klass, options)
        records = klass.page(controller.params[:page]).per(controller.params[:per_page])
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
