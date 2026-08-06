# frozen_string_literal: true

shared_examples 'simple crud for show with html' do
  describe 'GET #show with html rendering' do
    let!(:record) { create(model_class) }

    before { get "/html_show/dummy_models/#{record.id}" }

    it 'responds with ok status' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end

    it 'exposes the record to the view' do
      expect(response.body).to include(record.name)
    end
  end
end
