# frozen_string_literal: true

require 'spec_helper'

describe CachedDefaults::DummyModelsController, type: :controller do
  before { Rails.cache.clear }

  include_examples 'simple crud for show'

  describe 'GET #index' do
    before { create_list(:dummy_model, 2) }

    it 'returns all records' do
      get :index
      expect(response.parsed_body.length).to eq(2)
    end
  end
end
