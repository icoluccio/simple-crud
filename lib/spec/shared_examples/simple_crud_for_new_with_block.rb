# frozen_string_literal: true

RSpec.shared_examples 'simple crud for new with block' do
  describe 'GET #new with a render block' do
    include_context 'with authenticated user' if check_authenticate(:new)

    before do
      make_policies_succeed(:new) if check_authorize(:new)
      get :new, params: with_route_params({}), format: request_format(:new)
    end

    if check_html(:new)
      include_examples 'simple crud renders template', :new
    else
      it 'renders the built record through the block' do
        expect(response).to be_successful
      end
    end
  end
end
