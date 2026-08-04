source 'https://rubygems.org'

# Declare your gem's dependencies in simple-crud.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development, :test do
  gem 'action_policy', '~> 0.7.6', require: false
  gem 'active_model_serializers', '~> 0.10.16'
  gem 'appraisal', '~> 2.5'
  gem 'byebug', '~> 13.0'
  gem 'cancancan', '~> 3.6', require: false
  gem 'database_cleaner-active_record', '~> 2.2', require: 'database_cleaner/active_record'
  gem 'devise', '>= 4.9', '< 6'
  gem 'devise-jwt', '~> 0.13'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'faker', '~> 3.8'
  gem 'kaminari', '~> 1.2', require: false
  gem 'overcommit', '~> 0.72'
  gem 'pagy', '~> 43.0', require: false
  gem 'pundit', '~> 2.5'
  gem 'rake', '~> 13.4'
  gem 'rspec', '~> 3.13'
  gem 'rspec-rails', '>= 6.0', '< 9'
  gem 'rubocop', '~> 1.88'
  gem 'rubocop-rspec', '~> 3.10'
  gem 'simplecov', '~> 1.0'
  # sqlite3 is pinned per Rails version in Appraisals instead, since the
  # required range differs across supported versions.
  gem 'webmock', '~> 3.26'
  gem 'will_paginate', '~> 4.0', require: false
  gem 'wor-paginate', '~> 0.4'
end
