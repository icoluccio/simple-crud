# frozen_string_literal: true

shared_examples 'simple crud for destroy with html' do
  describe 'DELETE #destroy with html rendering' do
    let!(:record) { create(model_class) }

    it 'redirects to the collection on success', :aggregate_failures do
      delete "/html_destroy/dummy_models/#{record.id}"

      expect(response).to have_http_status(:found)
      expect(response.location).to match(%r{/dummy_models$})
      expect(model_class_object.exists?(record.id)).to be false
    end
  end
end
