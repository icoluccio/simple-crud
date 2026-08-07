# frozen_string_literal: true

RSpec.shared_context 'with authenticated user' do
  before { authenticate_request }
end
