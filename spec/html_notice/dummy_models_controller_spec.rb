# frozen_string_literal: true

require 'spec_helper'

describe HtmlNotice::DummyModelsController, type: :controller do
  describe 'POST #create' do
    it 'flashes the notice on success' do
      post :create, params: attributes_for(:dummy_model).merge(user_id: create(:user).id), format: :html

      expect(flash[:notice]).to eq('created')
    end
  end

  describe 'PUT #update' do
    let(:record) { create(:dummy_model) }

    it 'flashes the notice on success' do
      put :update, params: { id: record.id, name: 'renamed' }, format: :html

      expect(flash[:notice]).to eq('updated')
    end

    it 'flashes the alert on failure' do
      put :update, params: { id: record.id, name: nil }, format: :html

      expect(flash.now[:alert]).to eq('invalid')
    end
  end

  describe 'DELETE #destroy' do
    it 'flashes the notice on success' do
      record = create(:dummy_model)
      delete :destroy, params: { id: record.id }, format: :html

      expect(flash[:notice]).to eq('removed')
    end
  end
end
