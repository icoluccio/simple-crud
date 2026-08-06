# frozen_string_literal: true

shared_examples 'simple crud for update with html' do
  describe 'PUT #update with html rendering' do
    let!(:record) { create(model_class) }

    it 'redirects to the updated record on success', :aggregate_failures do
      put "/html_update/dummy_models/#{record.id}", params: { name: 'Updated' }

      expect(response).to have_http_status(:found)
      expect(response.location).to match(%r{/dummy_models/#{record.id}})
    end

    it 're-renders the edit template on failure', :aggregate_failures do
      put "/html_update/dummy_models/#{record.id}", params: { name: nil }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end
  end
end
