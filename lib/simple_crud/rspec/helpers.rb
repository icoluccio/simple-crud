# frozen_string_literal: true

require_relative 'helpers/settings'
require_relative 'helpers/controller_options'
require_relative 'helpers/models'
require_relative 'helpers/authentication'
require_relative 'helpers/requests'
require_relative 'helpers/policies'

module SimpleCrud
  module RSpec
    # Helpers available to the shared examples (and to apps that include
    # them), composed from focused sub-modules: settings resolution,
    # controller-option introspection, record building, authentication,
    # request params and policy access.
    module Helpers
      include Settings
      include ControllerOptions
      include Models
      include Authentication
      include Requests
      include Policies
    end
  end
end
