# frozen_string_literal: true

RSpec.shared_examples 'simple crud without authenticated user' do |action|
  context 'without authenticated user' do
    subject!(:req) { get action, params: with_route_params({}) }

    include_examples 'unauthorized when not logged in' if check_authenticate(action)
  end
end
