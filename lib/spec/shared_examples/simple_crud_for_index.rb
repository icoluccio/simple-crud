# frozen_string_literal: true

shared_examples 'simple crud for index' do
  describe 'GET #index' do
    let(:created_models) { create_records(model_class, 10, model_attributes) }

    before { created_models }

    include_examples 'simple crud without authenticated user', :index
    include_examples 'simple crud when not authorized', :index, :get

    context 'with authenticated user' do
      include_context 'with authenticated user' if check_authenticate(:index)

      before do
        make_policies_succeed(:index)
        get :index, format: request_format(:index)
      end

      if check_html(:index)
        include_examples 'simple crud renders template', :index
      elsif check_paginate(:index)
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
