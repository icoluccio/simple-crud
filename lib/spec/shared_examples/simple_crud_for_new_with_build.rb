# frozen_string_literal: true

shared_examples 'simple crud for new with build' do
  describe 'GET #new with a build hook' do
    include_context 'with authenticated user'

    before { get :new }

    it 'builds the record owned by the current user' do
      expect(response_body['user_id']).to eq(current_user.id)
    end
  end
end
