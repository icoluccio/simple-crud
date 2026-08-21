# frozen_string_literal: true

shared_examples 'unauthorized when not logged in' do
  context 'when the user is not logged in' do
    it 'returns the unauthenticated status' do
      req
      expect(response).to have_http_status(unauthenticated_status)
    end
  end
end
