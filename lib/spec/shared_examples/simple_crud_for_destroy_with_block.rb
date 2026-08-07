# frozen_string_literal: true

shared_examples 'simple crud for destroy with block' do
  describe 'DELETE #destroy with a render block' do
    let!(:record) { create(model_class) }

    before { delete "/block_destroy/dummy_models/#{record.id}" }

    it 'passes the destroyed record to the block' do
      expect(response.parsed_body).to eq('destroyed' => true)
    end
  end
end
