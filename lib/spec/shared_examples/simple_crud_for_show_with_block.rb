# frozen_string_literal: true

shared_examples 'simple crud for show with block' do
  describe 'GET #show with a render block' do
    let!(:record) { create(model_class) }

    before { get "/block_show/dummy_models/#{record.id}" }

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end

    it 'passes the record to the block' do
      expect(response.body).to include(record.name)
    end
  end
end
