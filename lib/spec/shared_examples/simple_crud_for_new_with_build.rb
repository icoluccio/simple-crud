# frozen_string_literal: true

shared_examples 'simple crud for new with build' do
  describe 'GET #new with a build hook' do
    include_context 'with authenticated user' if check_authenticate(:new)

    before do
      get :new, params: with_route_params({}), format: request_format(:new)
    end

    it 'builds the record owned by the current user' do
      expect(response_body[owner_foreign_key.to_s]).to eq(current_user.id)
    end
  end
end
