# frozen_string_literal: true

require 'spec_helper'

describe Strict::DummyModelsController, type: :controller do
  include_examples 'simple crud for create'
  include_examples 'simple crud for update'

  describe 'with raise_on_invalid' do
    include_context 'with authenticated user'

    it 'raises on invalid create, rescued to unprocessable' do
      post :create, params: { user_id: current_user.id }
      expect(response).to have_http_status(ApplicationController::UNPROCESSABLE_STATUS)
    end

    it 'raises on invalid update, rescued to unprocessable' do
      record = create(:dummy_model, user: current_user)
      put :update, params: { id: record.id, name: nil, user_id: current_user.id }
      expect(response).to have_http_status(ApplicationController::UNPROCESSABLE_STATUS)
    end
  end
end
