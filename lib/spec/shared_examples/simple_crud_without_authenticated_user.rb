# frozen_string_literal: true

shared_examples 'simple crud without authenticated user' do |action|
  context 'without authenticated user' do
    subject!(:req) { get action }

    include_examples 'unauthorized when not logged in' if check_authenticate(action)
  end
end
