# frozen_string_literal: true

require_relative 'helpers'

shared_examples 'simple crud for create' do
  describe 'POST #create' do
    context 'without authenticated user' do
      subject!(:req) { post :create, params: attributes_for(model_class) }

      include_examples 'unauthorized when not logged in' if check_authenticate(:create)
    end

    if check_authorize(:create)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          make_policies_fail(:create)
          post :create, params: model_params
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when successfully creating an article' do
      include_context 'with authenticated user' if check_authenticate(:create)
      let(:create_params) { model_params.merge(user_id: current_user.id) }

      before do
        post :create, params: create_params
      end

      it 'response with 200 status code' do
        expect(response).to have_http_status(:created)
      end

      it 'creates an article' do
        expect(model_class_object.count).to be 1
      end

      it 'creates an article with valid attributes' do
        expect(model_class_object.last).to have_attributes(create_params)
      end
    end
  end
end
