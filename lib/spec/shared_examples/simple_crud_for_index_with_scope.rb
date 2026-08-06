# frozen_string_literal: true

shared_examples 'simple crud for index with scope' do
  describe 'GET #index with a custom scope' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:my_models) { create_list(:dummy_model, 2, user: user) }
    let(:other_models) { create_list(:dummy_model, 3, user: other_user) }

    before do
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
      request.headers.merge!(Devise::JWT::TestHelpers.auth_headers(headers, user))
      make_policies_succeed(:index)
      my_models
      other_models
      get :index
    end

    it 'returns only the scoped records' do
      expect(response_body['page'].map { |m| m['id'] }).to match_array(my_models.map(&:id))
    end
  end
end
