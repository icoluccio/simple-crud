# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Definition-time introspection of the options each action was declared
      # with via simple_crud_for (read from the controller's metadata).
      module ControllerOptions
        def get_option(method, option)
          described_class.instance_variable_get(:@simple_crud_metadata)[method][option]
        end

        %i[paginate authorize authenticate serializer html finder scope build raise_on_invalid block].each do |option|
          define_method("check_#{option}") { |method| get_option(method, option) }
        end
      end
    end
  end
end
