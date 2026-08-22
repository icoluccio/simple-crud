# frozen_string_literal: true

shared_examples 'simple crud for destroy with finder' do
  describe 'DELETE #destroy with a custom finder' do
    include_context 'with authenticated user' if check_authenticate(:destroy)

    context 'when the model exists' do
      before do
        model
        delete :destroy, params: with_route_params(finder_key => model.public_send(finder_key)),
                         format: request_format(:destroy)
      end

      it 'destroys the model' do
        expect(model_class_object.exists?(model.id)).to be false
      end

      if check_block(:destroy)
        it 'passes the destroyed record to the block' do
          expect(rendered_record.id).to eq(model.id)
        end
      elsif check_html(:destroy)
        it 'redirects to the collection' do
          expect(response).to have_http_status(:found)
        end
      else
        it 'responds with ok status' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    include_examples 'simple crud not found with finder', :delete, :destroy
  end
end
