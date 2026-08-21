# frozen_string_literal: true

shared_examples 'simple crud for create' do
  describe 'POST #create' do
    context 'without authenticated user' do
      subject!(:req) do
        post :create, params: with_route_params(body_params(params_for(model_class))), format: request_format(:create)
      end

      include_examples 'unauthorized when not logged in' if check_authenticate(:create)
    end

    if check_authorize(:create)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          make_policies_fail(:create)
          post :create, params: with_route_params(body_params(model_params)), format: request_format(:create)
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when successfully creating an article' do
      include_context 'with authenticated user' if check_authenticate(:create)
      let(:create_params) { model_params.merge(owner_params) }

      before do
        post :create, params: with_route_params(body_params(create_params)), format: request_format(:create)
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

      it 'creates the record', :aggregate_failures do
        expect(model_class_object.count).to be 1
        instance_exec(model_class_object.last, &created_record_check) if created_record_check
      end
    end

    unless check_raise_on_invalid(:create)
      context 'when creating with invalid attributes' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          post :create, params: with_route_params(body_params(owner_params)), format: request_format(:create)
        end

        unless check_block(:create)
          if check_html(:create)
            include_examples 'simple crud renders template', :new, -> { invalid_status }
          else
            it 'responds with unprocessable entity' do
              expect(response).to have_http_status(unprocessable_status)
            end

            it 'returns the validation errors' do
              expect(response_body['errors']).to include(required_error)
            end
          end
        end

        it 'does not create a model' do
          expect(model_class_object.count).to be 0
        end
      end
    end
  end
end
