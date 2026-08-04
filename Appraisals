# sqlite3 is pinned per Rails version here, not in the Gemfile: activerecord
# 6.1/7.0 hard-pin "~> 1.4" internally, 8.0/8.1 need ">= 2.1", and Bundler
# won't allow the same gem pinned twice in one Gemfile.

appraise 'rails-6.1' do
  gem 'rails', '~> 6.1.0'

  # activesupport 6.1.x uses mutex_m/benchmark/logger without declaring
  # them, and none is bundled by default on Ruby 3.4+/4.0+ anymore.
  gem 'mutex_m'
  gem 'benchmark'
  gem 'logger'

  gem 'sqlite3', '~> 1.4'
end

appraise 'rails-7.0' do
  gem 'rails', '~> 7.0.0'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails-7.1' do
  gem 'rails', '~> 7.1.0'
  gem 'sqlite3', '~> 2.9'
end

appraise 'rails-7.2' do
  gem 'rails', '~> 7.2.0'
  gem 'sqlite3', '~> 2.9'
end

appraise 'rails-8.0' do
  gem 'rails', '~> 8.0.0'
  gem 'sqlite3', '~> 2.9'
end

appraise 'rails-8.1' do
  gem 'rails', '~> 8.1.0'
  gem 'sqlite3', '~> 2.9'
end
