# frozen_string_literal: true

shared_examples 'simple crud for update' do
  describe 'PUT #update' do
    context 'without authenticated user' do
      subject!(:req) { put :update, params: attributes_for(model_class).merge(id: model.id) }

      include_examples 'unauthorized when not logged in'
    end

    if check_authorize(:update)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:update)

        before do
          make_policies_fail(:update)
          put :update, params: model_params.merge(id: model.id)
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when successfully updating an model' do
      include_context 'with authenticated user'

      before do
        model
        put :update, params: model_params.merge(id: model.id)
      end

      it 'response with 200 status code' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates an model' do
        expect(model_class_object.count).to be 1
      end

      it 'updates an model with valid attributes' do
        expect(model_class.classify.constantize.last).to have_attributes(model_params)
      end
    end

    context 'when updating a model that doesn\'t exist' do
      include_context 'with authenticated user'

      before { put :update, params: { id: 1 } }

      it 'response with 422 status code' do
        expect(response).to have_http_status(:not_found)
      end

      it 'doesn\'t create an model' do
        expect(model_class_object.count).to be 0
      end
    end

    unless check_raise_on_invalid(:update)
      context 'when updating with invalid attributes' do
        include_context 'with authenticated user'

        before do
          model
          put :update, params: { id: model.id, name: nil, user_id: current_user.id }
        end

        it 'responds with unprocessable entity' do
          expect(response).to have_http_status(unprocessable_status)
        end

        it 'returns the validation errors' do
          expect(response_body['errors']).to include("Name can't be blank")
        end
      end
    end
  end
end
