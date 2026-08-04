# frozen_string_literal: true

shared_examples 'simple crud for show' do
  describe 'GET #show' do
    subject(:show_request) { get :show, params: show_params }

    before do
      model
    end

    context 'without authenticated user' do
      subject!(:req) { get :show, params: { id: model.id } }

      include_examples 'unauthorized when not logged in'
    end

    describe 'when the model exists' do
      include_context 'with authenticated user'
      let(:show_params) { { id: model.id } }

      before do
        show_request
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the asked model' do
        expect(response_body['id']).to eq(model.id)
      end

      it 'have been serializer with model Serializer' do
        expect(response_body).to have_been_serialized_with(model_serializer)
      end
    end

    describe 'when the model does not exist' do
      include_context 'with authenticated user'
      let(:show_params) { { id: -1 } }

      before do
        show_request
      end

      it 'responds with not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
