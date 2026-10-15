# frozen_string_literal: true

RSpec::Matchers.define :render_or_redirect do
  match { |response| response.successful? || response.redirect? }

  failure_message { |response| "expected a 2xx render or a redirect, got #{response.status}" }
end
