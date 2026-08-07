# frozen_string_literal: true

require 'spec_helper'

describe RedirectAuth::DummyModelsController, type: :controller do
  around do |example|
    original = SimpleCrud::RSpec::Config.instance.unauthenticated_status
    SimpleCrud::RSpec.configure { |c| c.unauthenticated_status = :found }
    example.run
    SimpleCrud::RSpec.configure { |c| c.unauthenticated_status = original }
  end

  include_examples 'simple crud for index'
end
