# frozen_string_literal: true

require 'spec_helper'

describe Cached::DummyModelsController, type: :controller do
  before { Rails.cache.clear }

  include_examples 'simple crud for show with finder'

  describe 'GET #show' do
    let!(:record) { create(:dummy_model) }

    it 'serves from cache on repeated requests' do
      get :show, params: { slug: record.slug }
      first_body = response.parsed_body

      record.update!(name: 'updated')
      get :show, params: { slug: record.slug }

      expect(response.parsed_body).to eq(first_body)
    end
  end
end
