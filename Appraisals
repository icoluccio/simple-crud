# sqlite3 is pinned per Rails version here, not in the Gemfile: activerecord
# 6.1/7.0 hard-pin "~> 1.4" internally, 8.0/8.1 need ">= 2.1", and Bundler
# won't allow the same gem pinned twice in one Gemfile.

appraise 'rails-6.1' do
  gem 'rails', '~> 6.1.0'

  # activesupport 6.1.x requires mutex_m without declaring it; Ruby 3.4+ no
  # longer bundles it by default.
  gem 'mutex_m'

  # Same issue for benchmark, removed by default in Ruby 4.0.
  gem 'benchmark'

  # Same issue for logger, no longer auto-loaded by default since Ruby 3.4.
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
