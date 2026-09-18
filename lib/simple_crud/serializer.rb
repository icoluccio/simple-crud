# frozen_string_literal: true

module SimpleCrud
  # Precedence: Blueprinter, then a plain class .render, then ActiveModelSerializers.
  module Serializer
    def self.render(serializer, record, options = {})
      return record.as_json if serializer.nil?
      return serializer.render_as_hash(record, options) if serializer.respond_to?(:render_as_hash)
      return serializer.render(record, **options) if serializer.is_a?(Class) && serializer.respond_to?(:render)

      serializer.new(record, options).as_json
    end
  end
end
