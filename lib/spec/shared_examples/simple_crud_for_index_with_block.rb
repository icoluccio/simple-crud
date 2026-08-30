# frozen_string_literal: true

RSpec.shared_examples 'simple crud for index with block' do
  describe 'GET #index with a render block' do
    let(:created_models) { create_records(model_class, 2, model_attributes) }

    include_context 'with authenticated user' if check_authenticate(:index)

    before do
      created_models
      get :index, params: with_route_params({}), format: request_format(:index)
    end

    if check_html(:index)
      include_examples 'simple crud renders template', :index
    else
      it 'renders the records through the block' do
        expect(response).to be_successful
      end
    end
  end
end
