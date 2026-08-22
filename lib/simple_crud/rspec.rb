# frozen_string_literal: true

require_relative 'rspec/config'
require_relative 'rspec/helpers'
require_relative '../spec/response_helper'
require_relative '../spec/shared_contexts/authenticate_user'
require_relative '../spec/shared_examples/simple_crud_for_update'
require_relative '../spec/shared_examples/simple_crud_for_show'
require_relative '../spec/shared_examples/simple_crud_for_index'
require_relative '../spec/shared_examples/simple_crud_for_destroy'
require_relative '../spec/shared_examples/simple_crud_for_create'
require_relative '../spec/shared_examples/simple_crud_for_new'
require_relative '../spec/shared_examples/simple_crud_for_edit'
require_relative '../spec/shared_examples/unauthorized_when_not_logged_in'
require_relative '../spec/shared_examples/simple_crud_renders_template'
require_relative '../spec/shared_examples/simple_crud_without_authenticated_user'
require_relative '../spec/shared_examples/simple_crud_when_not_authorized'
require_relative '../spec/shared_examples/simple_crud_for_index_with_block'
require_relative '../spec/shared_examples/simple_crud_for_index_with_scope'
require_relative '../spec/shared_examples/simple_crud_for_show_with_block'
require_relative '../spec/shared_examples/simple_crud_for_new_with_block'
require_relative '../spec/shared_examples/simple_crud_for_create_with_block'
require_relative '../spec/shared_examples/simple_crud_for_destroy_with_block'
require_relative '../spec/shared_examples/simple_crud_for_show_with_finder'
require_relative '../spec/shared_examples/simple_crud_for_update_with_finder'
require_relative '../spec/shared_examples/simple_crud_for_destroy_with_finder'
require_relative '../spec/shared_examples/simple_crud_not_found_with_finder'
require_relative '../spec/shared_examples/simple_crud_for_new_with_build'
require_relative '../spec/shared_examples/simple_crud_for_create_with_build'
require_relative '../spec/shared_examples/authorization_adapter_authorize'
require_relative '../spec/matchers/have_been_serialized_with'

module SimpleCrud
  # Opt-in wiring for the shared examples: see .install!
  module RSpec
    # Opt-in wiring: call from your spec support after requiring this file.
    # extend wires definition-time helpers (check_html...), include runtime ones (model...).
    def self.install!
      ::RSpec.configure do |config|
        config.extend Helpers
        config.include Helpers
        config.include Response::JSONParser, type: :controller
      end
    end
  end
end
