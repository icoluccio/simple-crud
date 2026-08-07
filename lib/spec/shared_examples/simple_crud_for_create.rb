# frozen_string_literal: true

shared_examples 'simple crud for create' do
  describe 'POST #create' do
    context 'without authenticated user' do
      subject!(:req) { post :create, params: params_for(model_class), format: request_format(:create) }

      include_examples 'unauthorized when not logged in' if check_authenticate(:create)
    end

    if check_authorize(:create)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          make_policies_fail(:create)
          post :create, params: model_params, format: request_format(:create)
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when successfully creating an article' do
      include_context 'with authenticated user' if check_authenticate(:create)
      let(:create_params) { model_params.merge(owner_foreign_key => current_user.id) }

      before do
        post :create, params: create_params, format: request_format(:create)
      end

      if check_html(:create)
        it 'redirects to the created record' do
          expect(response).to have_http_status(:found)
        end
      else
        it 'response with 201 status code' do
          expect(response).to have_http_status(:created)
        end

        it 'creates an article with valid attributes' do
          expect(model_class_object.last).to have_attributes(create_params)
        end
      end

      it 'creates the record' do
        expect(model_class_object.count).to be 1
      end
    end

    unless check_raise_on_invalid(:create)
      context 'when creating with invalid attributes' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          post :create, params: { owner_foreign_key => current_user.id }, format: request_format(:create)
        end

        if check_html(:create)
          include_examples 'simple crud renders template', :new
        else
          it 'responds with unprocessable entity' do
            expect(response).to have_http_status(unprocessable_status)
          end

          it 'returns the validation errors' do
            expect(response_body['errors']).to include(required_error)
          end

          it 'does not create a model' do
            expect(model_class_object.count).to be 0
          end
        end
      end
    end
  end
end
