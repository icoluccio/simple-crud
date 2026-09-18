# frozen_string_literal: true

require 'spec_helper'

describe Parented::DummyModelsController, simple_crud: {
  route_params: -> { { owner_id: current_user.id } }
}, type: :controller do
  let(:owner) { create(:user) }

  include_examples 'simple crud for nested resource'

  describe 'POST #create' do
    include_context 'with authenticated user'

    it 'builds the record through the parent association' do
      post :create, params: { owner_id: owner.id, name: 'from parent' }, format: :json

      expect(owner.dummy_models.find(response.parsed_body['id']).name).to eq('from parent')
    end
  end

  describe 'POST #create with parent: and owned_by: together' do
    it 'raises, they are the same relation source' do
      expect do
        described_class.simple_crud_for(:show, parent: :owner, owned_by: :dummy_models)
      end.to raise_error(ArgumentError, /mutually exclusive/)
    end
  end
end
