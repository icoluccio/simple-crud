# frozen_string_literal: true

RSpec.shared_examples 'simple crud for edit with finder' do
  describe 'GET #edit with a custom finder' do
    include_context 'with authenticated user' if check_authenticate(:edit)

    context 'when the model exists' do
      before do
        model
        make_policies_succeed(:edit, permissive: check_block(:edit)) if check_authorize(:edit)
        get :edit, params: with_route_params(finder_key => model.public_send(finder_key)),
                   format: format_param(:edit)
      end

      if check_block(:edit)
        it 'finds the asked model' do
          expect(rendered_record.id).to eq(model.id)
        end
      elsif check_html(:edit)
        include_examples 'simple crud renders template', :edit
      else
        it 'responds with ok status' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the asked model' do
          expect(response_body['id']).to eq(model.id)
        end
      end
    end

    include_examples 'simple crud not found with finder', :get, :edit
  end
end
