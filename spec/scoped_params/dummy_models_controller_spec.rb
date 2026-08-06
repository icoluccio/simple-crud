# frozen_string_literal: true

require 'spec_helper'

describe ScopedParams::DummyModelsController, type: :controller do
  include_examples 'simple crud for index with scope' do
    let(:my_models) { create_list(:dummy_model, 2, user: user, something: 42) }
    let(:other_models) { create_list(:dummy_model, 1, user: user, something: 7) }
    let(:request_params) { { something: 42 } }
  end
end
