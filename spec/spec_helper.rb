# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  minimum_coverage 100
end

require File.expand_path('../spec/dummy/config/environment.rb', __dir__)
require 'simple_crud'
require 'rspec/rails'
require 'pundit/rspec'
require 'wor/paginate/rspec'
require 'simple_crud/rspec'
require 'devise'
require 'devise/jwt/test_helpers'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

ActiveRecord::Migrator.migrations_paths = [File.expand_path('../spec/dummy/db/migrate', __dir__)]

RSpec.configure do |config|
  config.include ActionDispatch::TestProcess
  config.file_fixture_path = Rails.root.join('spec', 'support', 'fixtures')

  config.infer_spec_type_from_file_location!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
  config.include Response::JSONParser, type: :controller
  config.order = 'random'

  # DatabaseCleaner already wraps each example in a transaction below.
  # rspec-rails's own wrapping double-nests it and was observed to leak
  # committed rows. Disable it here.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    # Warms the schema cache before any DatabaseCleaner transaction opens.
    # Otherwise the first example touching a table triggers a PRAGMA
    # table_info query mid-transaction, which silently ends it and commits
    # that example's rows for real instead of rolling back.
    conn = ActiveRecord::Base.connection
    conn.data_sources.each { |t| conn.schema_cache.add(t) }
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

ActiveRecord::Migration.maintain_test_schema!

require 'byebug'
