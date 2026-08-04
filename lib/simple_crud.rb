# frozen_string_literal: true

require_relative 'simple_crud/version'
require_relative 'simple_crud/config'
require_relative 'simple_crud/simple_crud_controller'

# Simplified CRUD endpoints for Rails API controllers.
module SimpleCrud
  # Yields SimpleCrud::Config, e.g. to swap the authorization adapter:
  #   SimpleCrud.configure do |config|
  #     config.authorization_adapter = MyCanCanCanAdapter.new
  #   end
  def self.configure
    yield Config
  end
end
