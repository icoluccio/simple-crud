# frozen_string_literal: true

module SimpleCrud
  # Renders a record with the app's serializer stack.
  #
  # Blueprinter blueprints respond to `render_as_hash` and receive the
  # render options, so a blueprint can read `url_builder:` (or any other
  # option) from them. For anything else, simple_crud assumes an
  # ActiveModelSerializers-style serializer and calls `new(record, options)`.
  # A `nil` serializer renders `record.as_json`.
  module Serializer
    def self.render(serializer, record, options = {})
      return record.as_json if serializer.nil?
      return serializer.render_as_hash(record, options) if serializer.respond_to?(:render_as_hash)

      serializer.new(record, options).as_json
    end
  end
end
