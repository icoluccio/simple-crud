# frozen_string_literal: true

shared_examples 'simple crud for index with html' do
  describe 'GET #index with html rendering' do
    let(:created_models) { create_list(model_class, 10) }

    before do
      created_models
      get '/html/dummy_models'
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end

    it 'responds with html' do
      expect(response.media_type).to eq('text/html')
    end

    it 'renders the records in the template' do
      created_models.each { |record| expect(response.body).to include(record.name) }
    end
  end
end
