# frozen_string_literal: true

shared_examples 'simple crud for show with block' do
  describe 'GET #show with a render block' do
    let!(:record) { model }

    before { get :show, params: with_route_params({ id: record.id }), format: :html }

    include_examples 'simple crud renders template', :show
  end
end
