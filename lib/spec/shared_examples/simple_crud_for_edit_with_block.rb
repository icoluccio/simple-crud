# frozen_string_literal: true

RSpec.shared_examples 'simple crud for edit with block' do
  describe 'GET #edit with a render block' do
    include_context 'with authenticated user' if check_authenticate(:edit)

    let!(:record) { model }

    before do
      make_policies_succeed(:edit, permissive: true) if check_authorize(:edit)
      get :edit, params: with_route_params(record_param(:edit, record)), format: format_param(:edit)
    end

    if check_html(:edit)
      include_examples 'simple crud renders template', :edit
    else
      it 'renders the record through the block' do
        expect(response).to render_or_redirect
      end
    end
  end
end
