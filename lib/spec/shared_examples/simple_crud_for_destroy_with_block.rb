# frozen_string_literal: true

RSpec.shared_examples 'simple crud for destroy with block' do
  describe 'DELETE #destroy with a render block' do
    include_context 'with authenticated user' if check_authenticate(:destroy)

    let!(:record) { model }

    before do
      delete :destroy, params: with_route_params(record_param(:destroy, record)), format: request_format(:destroy)
    end

    it 'passes the destroyed record to the block' do
      expect(response).to be_successful
    end

    it 'destroys the record' do
      expect(model_class_object.exists?(record.id)).to be false
    end
  end
end
