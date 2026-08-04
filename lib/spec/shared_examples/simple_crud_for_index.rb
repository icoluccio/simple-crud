# frozen_string_literal: true

shared_examples 'simple crud for index' do
  describe 'GET #index' do
    let(:created_models) { create_list(model_class, 10) }

    before { created_models }

    context 'without authenticated user' do
      subject!(:req) { get :index }

      include_examples 'unauthorized when not logged in' if check_authenticate(:index)
    end

    if check_authorize(:index)
      context 'when not authorized' do
        include_context 'with authenticated user' if check_authenticate(:index)

        before do
          make_policies_fail(:index)
          get :index
        end

        it 'fails with forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'with authenticated user' do
      include_context 'with authenticated user' if check_authenticate(:index)
      before do
        make_policies_succeed(:index)
        get :index
      end

      if check_paginate(:index)
        it 'renders paginated models correctly serialized' do
          expect(response_body['page']).to have_been_serialized_with(model_serializer)
        end

        it 'renders the correct paginated models' do
          expect(response_body['page'].map { |a| a['id'] }).to eq(model_class_object.all.map(&:id))
        end
      else
        it 'renders unpaginated models correctly serialized' do
          expect(response_body).to have_been_serialized_with(model_serializer)
        end

        it 'renders the correct unpaginated models' do
          expect(response_body.map { |a| a['id'] }).to eq(model_class_object.all.map(&:id))
        end
      end
    end
  end
end
