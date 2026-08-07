# frozen_string_literal: true

shared_examples 'simple crud for update with finder' do
  describe 'PUT #update with a custom finder' do
    include_context 'with authenticated user'

    context 'when successfully updating a model' do
      let(:update_params) do
        {
          finder_key => model.public_send(finder_key),
          required_attribute => 'Updated',
          owner_foreign_key => current_user.id
        }
      end

      before do
        model
        put :update, params: update_params
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates the model' do
        expect(model.reload.public_send(required_attribute)).to eq('Updated')
      end
    end

    include_examples 'simple crud not found with finder', :put, :update
  end
end
