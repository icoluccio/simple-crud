# frozen_string_literal: true

require 'spec_helper'
describe DummyModelsController, type: :controller do
  include_examples 'simple crud for update'
  include_examples 'simple crud for show'
  include_examples 'simple crud for create'
  include_examples 'simple crud for index'
  include_examples 'simple crud for destroy'
  include_examples 'simple crud for new'

  describe 'POST #create with invalid attributes' do
    include_context 'with authenticated user'

    it 'responds with unprocessable entity' do
      post :create, params: { something: 1, user_id: current_user.id }
      expect(response).to have_http_status(ApplicationController::UNPROCESSABLE_STATUS)
    end
  end
end
