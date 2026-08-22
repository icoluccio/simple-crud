# frozen_string_literal: true

shared_examples 'simple crud for edit' do
  describe 'GET #edit' do
    subject(:edit_request) { get :edit, params: with_route_params(edit_params), format: request_format(:edit) }

    before do
      model
    end

    context 'without authenticated user' do
      subject!(:req) do
        get :edit, params: with_route_params(record_param(:edit, model)), format: request_format(:edit)
      end

      include_examples 'unauthorized when not logged in' if check_authenticate(:edit)
    end

    if check_authorize(:edit)
      context 'when the user is not authorized' do
        include_context 'with authenticated user' if check_authenticate(:edit)

        let(:edit_params) { record_param(:edit, model) }

        before do
          model
          make_policies_fail(:edit)
          edit_request
        end

        it 'responds with forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when the model exists' do
      include_context 'with authenticated user' if check_authenticate(:edit)

      let(:edit_params) { record_param(:edit, model) }

      before do
        model
        make_policies_succeed(:edit) if check_authorize(:edit)
        edit_request
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      if check_block(:edit)
        it 'renders the asked model through the block' do
          expect(response).to be_successful
        end
      elsif check_html(:edit)
        include_examples 'simple crud renders template', :edit
      else
        it 'returns the asked model' do
          expect(response_body['id']).to eq(model.id)
        end
      end
    end

    context 'when the model does not exist' do
      include_context 'with authenticated user'

      let(:edit_params) { record_param(:edit, nil, not_found: true) }

      before do
        edit_request
      end

      it 'responds with not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
