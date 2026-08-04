# frozen_string_literal: true

module Response
  # RSpec helper that parses the last response body as JSON.
  module JSONParser
    def response_body
      JSON.parse(response.body)
    end
  end
end
