# frozen_string_literal: true

shared_examples 'simple crud for create with block' do
  describe 'POST #create with a render block' do
    context 'when successfully creating a record' do
      include_context 'with authenticated user' if check_authenticate(:create)
      let(:create_params) { model_params.merge(owner_params) }

      before do
        post :create, params: with_route_params(body_params(create_params)), format: request_format(:create)
      end

      it 'passes the saved record to the block' do
        expect(response).to be_successful
      end

      it 'creates the record' do
        expect(model_class_object.count).to be 1
      end
    end

    unless check_raise_on_invalid(:create)
      context 'when creating with invalid attributes' do
        include_context 'with authenticated user' if check_authenticate(:create)

        before do
          post :create, params: with_route_params(body_params(owner_params)), format: request_format(:create)
        end

        it 'does not create a model' do
          expect(model_class_object.count).to be 0
        end
      end
    end
  end
end
