# frozen_string_literal: true

shared_examples 'simple crud for show with block' do
  describe 'GET #show with a render block' do
    include_context 'with authenticated user' if check_authenticate(:show)

    let!(:record) { model }

    before do
      make_policies_succeed(:show) if check_authorize(:show)
      get :show, params: with_route_params(record_param(:show, record)), format: request_format(:show)
    end

    if check_html(:show)
      include_examples 'simple crud renders template', :show
    else
      it 'renders the record through the block' do
        expect(response).to be_successful
      end
    end
  end
end
