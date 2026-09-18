# frozen_string_literal: true

# For a parent: controller. The parent in route_params must match the record's owner_association.
RSpec.shared_examples 'simple crud for nested resource' do
  describe 'parent: scoping' do
    include_context 'with authenticated user' if check_authenticate(:show)

    it 'finds a record inside the parent' do
      get :show, params: with_route_params(record_param(:show, model)), format: format_param(:show)

      expect(response).to have_http_status(:ok)
    end

    it 'returns not found for a record outside the parent' do
      outside = create_record(model_class, model_attributes.merge(owner_association => other_user))
      get :show, params: with_route_params(record_param(:show, outside)), format: format_param(:show)

      expect(response).to have_http_status(:not_found)
    end
  end
end
