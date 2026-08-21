# frozen_string_literal: true

shared_examples 'simple crud for index with scope' do
  let(:user) { current_user }
  let(:my_models) { create_records(model_class, 2, owner_association => user) }
  let(:other_models) { create_records(model_class, 3, owner_association => other_user) }
  let(:request_params) { {} }

  before do
    authenticate_request
    make_policies_succeed(:index)
    my_models
    other_models
    get :index, params: with_route_params(request_params)
  end

  it 'returns only the scoped records' do
    expect(response_body['page'].map { |m| m['id'] }).to match_array(my_models.map(&:id))
  end
end
