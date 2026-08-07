# frozen_string_literal: true

shared_examples 'simple crud for new with block' do
  describe 'GET #new with a render block' do
    before { get :new, format: :html }

    include_examples 'simple crud renders template', :new
  end
end
