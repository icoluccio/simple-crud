# frozen_string_literal: true

shared_examples 'simple crud for new' do
  describe 'GET #new' do
    include_examples 'simple crud without authenticated user', :new
    include_examples 'simple crud when not authorized', :new, :get

    context 'when building a new record' do
      include_context 'with authenticated user' if check_authenticate(:new)

      before do
        make_policies_succeed(:new)
        get :new
      end

      it 'responds with ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a blank record as json' do
        expect(response_body['id']).to be_nil
      end
    end
  end
end
