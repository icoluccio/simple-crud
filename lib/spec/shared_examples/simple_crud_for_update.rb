# frozen_string_literal: true

RSpec.shared_examples 'simple crud for update' do
  describe 'PUT #update' do
    context 'without authenticated user' do
      subject!(:req) do
        update_params = body_params(params_for(model_class)).merge(record_param(:update, model))
        put :update, params: with_route_params(update_params), format: request_format(:update)
      end

      include_examples 'unauthorized when not logged in' if check_authenticate(:update)
    end

    if check_authorize(:update)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:update)

        before do
          make_policies_fail(:update)
          put :update, params: with_route_params(body_params(model_params).merge(record_param(:update, model))),
                       format: request_format(:update)
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when successfully updating an model' do
      include_context 'with authenticated user' if check_authenticate(:update)
      let(:update_params) { body_params(model_params).merge(record_param(:update, model)) }
      let(:update_attributes) { model_params.merge(record_param(:update, model).except(:id)) }

      before do
        model
        put :update, params: with_route_params(update_params), format: request_format(:update)
      end

      if check_html(:update)
        it 'redirects to the updated record' do
          expect(response).to have_http_status(:found)
        end
      else
        it 'response with 200 status code' do
          expect(response).to have_http_status(:ok)
        end

        it 'updates an model' do
          expect(model_class_object.count).to be 1
        end

        it 'updates an model with valid attributes' do
          expect(model_class_object.last).to have_attributes(update_attributes)
        end
      end

      it 'updates a record passing created_record_check', :aggregate_failures do
        expect(model_class_object.last).to be_present
        instance_exec(model_class_object.last, &created_record_check) if created_record_check
      end
    end

    context 'when updating a model that doesn\'t exist' do
      include_context 'with authenticated user'

      before do
        put :update, params: with_route_params(record_param(:update, nil, not_found: true)),
                     format: request_format(:update)
      end

      it 'response with 404 status code' do
        expect(response).to have_http_status(:not_found)
      end

      it 'doesn\'t create an model' do
        expect(model_class_object.count).to be 0
      end
    end

    unless check_raise_on_invalid(:update)
      context 'when updating with invalid attributes' do
        include_context 'with authenticated user' if check_authenticate(:update)

        before do
          model
          put :update, params: with_route_params(body_params({ required_attribute => nil }.merge(owner_params))
                                                         .merge(record_param(:update, model))),
                       format: request_format(:update)
        end

        unless check_block(:update)
          if check_html(:update)
            include_examples 'simple crud renders template', :edit, -> { invalid_status }
          else
            it 'responds with unprocessable entity' do
              expect(response).to have_http_status(unprocessable_status)
            end

            it 'returns the validation errors' do
              expect(response_body['errors']).to include(required_error)
            end
          end
        end
      end
    end
  end
end
