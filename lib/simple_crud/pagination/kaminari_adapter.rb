# frozen_string_literal: true

require 'kaminari'
require 'kaminari/activerecord'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # https://github.com/kaminari/kaminari
    class KaminariAdapter
      include Adapter

      def paginate(controller, klass, options)
        records = klass.page(controller.params[:page]).per(controller.params[:per_page])
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
