# frozen_string_literal: true

require_relative 'authorization/pundit_adapter'

module SimpleCrud
  # Holds simple_crud's configurable pieces. Set via SimpleCrud.configure.
  class Config
    class << self
      attr_writer :authorization_adapter

      def authorization_adapter
        @authorization_adapter ||= Authorization::PunditAdapter.new
      end
    end
  end
end
