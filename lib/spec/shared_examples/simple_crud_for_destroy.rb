# frozen_string_literal: true

shared_examples 'simple crud for destroy' do
  describe 'DELETE #destroy' do
    context 'without authenticated user' do
      subject!(:req) do
        delete :destroy, params: record_param(:destroy, nil, not_found: true), format: request_format(:destroy)
      end

      include_examples 'unauthorized when not logged in' if check_authenticate(:destroy)
    end

    if check_authorize(:destroy)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:destroy)

        before do
          make_policies_fail(:destroy)
          delete :destroy, params: record_param(:destroy, model), format: request_format(:destroy)
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when ID is valid' do
      include_context 'with authenticated user' if check_authenticate(:destroy)

      before do
        model
        delete :destroy, params: record_param(:destroy, model), format: request_format(:destroy)
      end

      if check_html(:destroy)
        it 'redirects to the collection and destroys the record', :aggregate_failures do
          expect(response).to have_http_status(:found)
          expect(model_class_object.exists?(model.id)).to be false
        end
      else
        it 'response with 200 status code' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when ID is invalid' do
      include_context 'with authenticated user' if check_authenticate(:destroy)

      before do
        model
        delete :destroy, params: record_param(:destroy, nil, not_found: true), format: request_format(:destroy)
      end

      it 'responds with not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    if check_authorize(:destroy)
      context 'when ID is valid but user isn\'t authorized' do
        include_context 'with authenticated user' if check_authenticate(:destroy)

        before do
          model
          make_policies_fail(:destroy)
          delete :destroy, params: record_param(:destroy, model), format: request_format(:destroy)
        end

        it 'responds with forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
