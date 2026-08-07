# frozen_string_literal: true

shared_examples 'simple crud for index with block' do
  describe 'GET #index with a render block' do
    let(:created_models) { create_records(model_class, 2, {}) }

    before do
      created_models
      get :index, format: :html
    end

    include_examples 'simple crud renders template', :index
  end
end
