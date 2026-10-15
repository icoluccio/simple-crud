# frozen_string_literal: true

RSpec.shared_examples 'simple crud for index with scope' do
  let(:request_params) { {} }
  let(:my_models) { create_records(model_class, 2, scoped_attributes) }
  let(:other_models) { create_records(model_class, 3, other_scoped_attributes) if other_scoped_attributes }
  let(:listed_ids) do
    if check_html(:index)
      rendered_records.map(&:id)
    else
      (check_paginate(:index) ? response_body['page'] : response_body).map { |m| m['id'] }
    end
  end

  # Hooks stay inside this context so co-including the example never
  # authenticates or stubs policies for sibling examples.
  context 'when listing the scoped records' do
    before do
      authenticate_request if check_authenticate(:index)
      make_policies_succeed(:index) if check_authorize(:index)
      my_models
      other_models
      get :index, params: with_route_params(request_params), format: format_param(:index)
    end

    it 'returns the scoped records' do
      expect(listed_ids).to match_array(my_models.map(&:id))
    end

    if scoped_order
      it 'returns the scoped records in order' do
        expect(listed_ids).to eq(instance_exec(my_models, &scoped_order).map(&:id))
      end
    end
  end
end
