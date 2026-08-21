# frozen_string_literal: true

require 'spec_helper'

describe Nested::DummyModelsController, type: :controller do
  around do |example|
    with_config_override(:params_key, :dummy_model) { example.run }
  end

  include_examples 'simple crud for create'
  include_examples 'simple crud for update'
end
