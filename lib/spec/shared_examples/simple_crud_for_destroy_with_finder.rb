# frozen_string_literal: true

shared_examples 'simple crud for destroy with finder' do
  describe 'DELETE #destroy with a custom finder' do
    include_context 'with authenticated user'

    context 'when the model exists' do
      before do
        model
        delete :destroy, params: { finder_key => model.public_send(finder_key) }
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'destroys the model' do
        expect(model_class_object.exists?(model.id)).to be false
      end
    end

    include_examples 'simple crud not found with finder', :delete, :destroy
  end
end
