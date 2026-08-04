# frozen_string_literal: true

module SimpleCrud
  # Holds simple_crud's configurable pieces. Set via SimpleCrud.configure.
  #
  # The default adapters (Pundit for authorization, wor-paginate for
  # pagination) are only required the first time they're actually needed,
  # so an app that never uses authorize: true or paginate: true never
  # needs either gem installed at all.
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
