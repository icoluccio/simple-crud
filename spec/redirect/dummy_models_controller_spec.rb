# frozen_string_literal: true

require 'spec_helper'

describe Redirect::DummyModelsController, type: :controller do
  describe 'POST #create' do
    it 'redirects to the target resolved from the redirect proc' do
      post :create, params: attributes_for(:dummy_model).merge(user_id: create(:user).id), format: :html

      expect(response).to redirect_to(dummy_models_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to the literal redirect path' do
      record = create(:dummy_model)

      delete :destroy, params: { id: record.id }, format: :html

      expect(response).to redirect_to('/block_new/dummy_models/new')
    end
  end
end
