# frozen_string_literal: true

shared_examples 'simple crud for index with block' do
  describe 'GET #index with a render block' do
    let(:created_models) { create_records(model_class, 2, {}) }

    before do
      created_models
      get :index, format: :html
    end

    it 'renders the index template', :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end
