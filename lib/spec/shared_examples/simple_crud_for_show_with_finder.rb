# frozen_string_literal: true

shared_examples 'simple crud for show with finder' do
  describe 'GET #show with a custom finder' do
    include_context 'with authenticated user' if check_authenticate(:show)

    context 'when the model exists' do
      before do
        model
        get :show, params: with_route_params(finder_key => model.public_send(finder_key)),
                   format: request_format(:show)
      end

      if check_block(:show)
        it 'finds the asked model' do
          expect(rendered_record.id).to eq(model.id)
        end
      elsif check_html(:show)
        include_examples 'simple crud renders template', :show
      else
        it 'responds with ok status' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the asked model' do
          expect(response_body['id']).to eq(model.id)
        end
      end
    end

    include_examples 'simple crud not found with finder', :get, :show
  end
end
