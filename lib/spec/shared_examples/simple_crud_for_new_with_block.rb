# frozen_string_literal: true

shared_examples 'simple crud for new with block' do
  describe 'GET #new with a render block' do
    before { get '/block_new/dummy_models/new' }

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end

    it 'passes the blank record to the block' do
      expect(response.body).to include('new true')
    end
  end
end
