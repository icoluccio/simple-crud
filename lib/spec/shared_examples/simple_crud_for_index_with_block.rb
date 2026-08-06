# frozen_string_literal: true

shared_examples 'simple crud for index with block' do
  describe 'GET #index with a render block' do
    let(:created_models) { create_list(model_class, 10) }

    before do
      created_models
      get '/block/dummy_models'
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end

    it 'passes the records to the block' do
      created_models.each { |record| expect(response.body).to include(record.name) }
    end
  end
end
