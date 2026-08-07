# frozen_string_literal: true

shared_examples 'simple crud for create with build' do
  describe 'POST #create with a build hook' do
    include_context 'with authenticated user'

    before do
      post :create, params: with_route_params(body_params({ name: 'Built' }))
    end

    it 'creates the record owned by the current user' do
      expect(model_class_object.last.public_send(owner_association)).to eq(current_user)
    end
  end
end
