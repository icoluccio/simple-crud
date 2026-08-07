# frozen_string_literal: true

shared_examples 'simple crud not found with finder' do |http_method, action|
  context 'when the model does not exist' do
    before do
      send(http_method, action, params: with_route_params(finder_key => "nonexistent-#{finder_key}"))
    end

    it 'responds with not found status' do
      expect(response).to have_http_status(:not_found)
    end
  end
end
