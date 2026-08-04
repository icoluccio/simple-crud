# frozen_string_literal: true

# Ruby 3.4+ no longer auto-loads logger by default; older Rails versions
# reference Logger::Severity without requiring it themselves.
require 'logger'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
