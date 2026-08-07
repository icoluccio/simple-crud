# frozen_string_literal: true

shared_examples 'simple crud for show with block' do
  describe 'GET #show with a render block' do
    let!(:record) { model }

    before { get :show, params: { id: record.id }, format: :html }

    it 'renders the show template', :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end
end
