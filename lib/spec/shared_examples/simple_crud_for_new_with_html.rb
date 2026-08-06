# frozen_string_literal: true

shared_examples 'simple crud for new with html' do
  describe 'GET #new with html rendering' do
    before { get '/html_new/dummy_models/new' }

    it 'responds with ok status' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end

    it 'builds a blank record for the view' do
      expect(response.body).to include('new true')
    end
  end
end
