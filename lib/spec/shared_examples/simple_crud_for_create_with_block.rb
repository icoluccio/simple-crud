# frozen_string_literal: true

shared_examples 'simple crud for create with block' do
  describe 'POST #create with a render block' do
    let!(:user) { create(:user) }

    it 'passes the saved record to the block' do
      post '/block_create/dummy_models', params: { name: 'Blocked', user_id: user.id }

      expect(response.parsed_body).to include('saved' => true)
    end

    it 'passes the failed record to the block', :aggregate_failures do
      post '/block_create/dummy_models', params: { user_id: user.id }

      expect(response).to have_http_status(422)
      expect(response.parsed_body).to include('saved' => false)
    end
  end
end
