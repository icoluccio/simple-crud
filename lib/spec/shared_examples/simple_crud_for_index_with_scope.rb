# frozen_string_literal: true

shared_examples 'simple crud for index with scope' do
  let(:request_params) { {} }
  let(:my_models) { create_records(model_class, 2, scoped_attributes) }
  let(:other_models) { create_records(model_class, 3, other_scoped_attributes) }

  # Hooks stay inside this context so co-including the example never
  # authenticates or stubs policies for sibling examples.
  context 'when listing the scoped records' do
    before do
      authenticate_request if check_authenticate(:index)
      make_policies_succeed(:index) if check_authorize(:index)
      my_models
      other_models
      get :index, params: with_route_params(request_params), format: request_format(:index)
    end

    if check_html(:index)
      it 'returns only the assigned scoped records' do
        expect(rendered_records.map(&:id)).to match_array(my_models.map(&:id))
      end
    elsif check_paginate(:index)
      it 'returns only the paginated scoped records' do
        expect(response_body['page'].map { |m| m['id'] }).to match_array(my_models.map(&:id))
      end
    else
      it 'returns only the unpaginated scoped records' do
        expect(response_body.map { |m| m['id'] }).to match_array(my_models.map(&:id))
      end
    end
  end
end
