# frozen_string_literal: true

shared_examples 'simple crud for update with finder' do
  describe 'PUT #update with a custom finder' do
    include_context 'with authenticated user'

    context 'when successfully updating a model' do
      let(:update_params) { { slug: model.slug, something: 42, user_id: current_user.id } }

      before do
        model
        put :update, params: update_params
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates the model' do
        expect(model.reload.something).to eq(42)
      end
    end

    context 'when the model does not exist' do
      before do
        put :update, params: { slug: 'nonexistent-slug', name: 'x', user_id: current_user.id }
      end

      it 'responds with not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
