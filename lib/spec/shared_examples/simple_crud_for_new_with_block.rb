# frozen_string_literal: true

shared_examples 'simple crud for new with block' do
  describe 'GET #new with a render block' do
    before { get :new, format: :html }

    it 'renders the new template', :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
end
