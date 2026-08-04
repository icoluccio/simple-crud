lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_crud/version"
require 'date'

Gem::Specification.new do |s|
  s.name        = "simple-crud"
  s.version     = SimpleCrud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today
  s.authors     = ["icoluccio"]
  s.email       = ["ignacio.coluccio@gmail.com"]
  s.homepage    = "https://github.com/icoluccio/simple-crud"
  s.summary     = "Simplified CRUD endpoints for Rails API controllers"
  s.description = "Simple CRUD is a gem for Rails that simplifies CRUD controllers, with default implementations and specs for common tasks"
  s.license     = "MIT"
  s.required_ruby_version = '>= 3.2'

  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']

  s.add_dependency 'rails', '>= 6.1', '< 9'
end
