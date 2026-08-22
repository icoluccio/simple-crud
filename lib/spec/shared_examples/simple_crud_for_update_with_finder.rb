# frozen_string_literal: true

shared_examples 'simple crud for update with finder' do
  describe 'PUT #update with a custom finder' do
    include_context 'with authenticated user' if check_authenticate(:update)

    context 'when successfully updating a model' do
      let(:update_params) do
        with_route_params(body_params(required_attribute => 'Updated').merge(owner_params))
          .merge(finder_key => model.public_send(finder_key))
      end

      before do
        model
        put :update, params: update_params, format: request_format(:update)
      end

      it 'updates the model' do
        expect(model.reload.public_send(required_attribute)).to eq('Updated')
      end

      if check_block(:update)
        it 'passes the updated model to the block' do
          expect(rendered_record.id).to eq(model.id)
        end
      elsif check_html(:update)
        it 'redirects to the updated record' do
          expect(response).to have_http_status(:found)
        end
      else
        it 'responds with ok status' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    include_examples 'simple crud not found with finder', :put, :update
  end
end
