# frozen_string_literal: true

module SimpleCrud
  # Holds simple_crud's configurable pieces, set via SimpleCrud.configure.
  class Config
    class << self
      attr_writer :authorization_adapter, :pagination_adapter

      def authorization_adapter
        @authorization_adapter ||= begin
          require_relative 'authorization/pundit_adapter'
          Authorization::PunditAdapter.new
        end
      end

      def pagination_adapter
        @pagination_adapter ||= begin
          require_relative 'pagination/wor_paginate_adapter'
          Pagination::WorPaginateAdapter.new
        end
      end
    end
  end
end
