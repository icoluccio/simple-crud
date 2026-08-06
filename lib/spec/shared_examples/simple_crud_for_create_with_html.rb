# frozen_string_literal: true

shared_examples 'simple crud for create with html' do
  describe 'POST #create with html rendering' do
    let!(:user) { create(:user) }

    it 'redirects to the created record on success', :aggregate_failures do
      post '/html_create/dummy_models', params: { name: 'Created', user_id: user.id }

      expect(response).to have_http_status(:found)
      expect(response.location).to match(%r{/dummy_models/\d+})
    end

    it 're-renders the new template on failure', :aggregate_failures do
      post '/html_create/dummy_models', params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
end
