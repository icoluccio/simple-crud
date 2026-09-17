# frozen_string_literal: true

require 'spec_helper'

describe Blueprint::DummyModelsController, type: :controller do
  let(:serializer) { DummyModelBlueprint }

  include_examples 'simple crud for index'
  include_examples 'simple crud for show'
  include_examples 'simple crud for create'
  include_examples 'simple crud for update'
  include_examples 'simple crud for destroy'

  describe 'GET #show' do
    include_context 'with authenticated user'

    let!(:record) { create(:dummy_model, user: current_user) }

    it 'passes serializer_options to the blueprint' do
      get :show, params: { id: record.id }

      expect(response.parsed_body['url']).to eq(dummy_model_url(record))
    end
  end
end
