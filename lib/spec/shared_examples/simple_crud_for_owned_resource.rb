# frozen_string_literal: true

# Include alongside the per-action examples for a controller using owned_by:.
RSpec.shared_examples 'simple crud for owned resource' do
  describe 'owned_by: scoping' do
    include_context 'with authenticated user'

    let!(:someone_elses_model) do
      create_record(model_class, model_attributes.merge(owner_association => other_user))
    end

    it 'returns not found for a record owned by another user' do
      get :show, params: with_route_params(record_param(:show, someone_elses_model)), format: format_param(:show)

      expect(response).to have_http_status(:not_found)
    end

    it 'ignores an attempt to update a record owned by another user', :aggregate_failures do
      params = with_route_params(record_param(:update, someone_elses_model)).merge(body_params(model_params))
      patch :update, params: params, format: format_param(:update)

      expect(response).to have_http_status(:not_found)
      expect(someone_elses_model.reload.public_send(required_attribute))
        .not_to eq(model_params[required_attribute])
    end

    it 'attributes a created record to the current user regardless of the request', :aggregate_failures do
      body = body_params(model_params.merge(owner_association => other_user.id))
      post :create, params: with_route_params(body), format: format_param(:create)

      expect(response).to have_http_status(check_status(:create) || :created)
      expect(model_class_object.last.public_send(owner_association)).to eq(current_user)
    end
  end
end
