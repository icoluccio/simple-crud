# frozen_string_literal: true

shared_examples 'simple crud for create with block' do
  describe 'POST #create with a render block' do
    it 'passes the saved record to the block' do
      post :create, params: with_route_params(body_params({ name: 'Blocked' }.merge(owner_params)))

      expect(response.parsed_body).to include('saved' => true)
    end

    it 'passes the failed record to the block', :aggregate_failures do
      post :create, params: with_route_params(body_params(owner_params))

      expect(response).to have_http_status(422)
      expect(response.parsed_body).to include('saved' => false)
    end
  end
end
