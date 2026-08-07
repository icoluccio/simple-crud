# frozen_string_literal: true

require 'spec_helper'

describe InvalidStatus::DummyModelsController, type: :controller do
  before { SimpleCrud::RSpec.configure { |c| c.invalid_status = 422 } }
  after { SimpleCrud::RSpec.configure { |c| c.invalid_status = :ok } }

  include_examples 'simple crud for create'
end
