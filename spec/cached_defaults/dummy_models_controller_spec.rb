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

  describe 'expire_simple_crud_cache' do
    let!(:record) { create(:dummy_model) }

    context 'when called after a cached show' do
      before { get :show, params: { id: record.id } }

      it 'clears the entry so the next request fetches fresh data' do
        first_body = response.parsed_body
        record.update!(name: 'updated')
        controller.expire_simple_crud_cache(:show)
        get :show, params: { id: record.id }
        expect(response.parsed_body).not_to eq(first_body)
      end
    end
  end
end
