# frozen_string_literal: true

RSpec::Matchers.define :have_been_serialized_with do |serializer|
  # TODO: Add support for optional relations `has_many :zarasa, if: zarasa2`
  # TODO: Support multilevel serialization
  match do |json_response|
    attributes  = serializer_attributes(serializer)
    reflections = serializer_reflections(serializer)

    [json_response].flatten.all? do |json_response_item|
      all_attributes_included?(attributes, json_response_item) &&
        all_attributes_included?(reflections, json_response_item)
    end
  end

  # Blueprinter blueprints expose their fields through the view collection;
  # ActiveModelSerializers expose `._attributes` / `._reflections`.
  def serializer_attributes(serializer)
    return serializer._attributes unless serializer.respond_to?(:view_collection)

    serializer.view_collection.fields_for(:default).map(&:name)
  end

  def serializer_reflections(serializer)
    return serializer._reflections.keys unless serializer.respond_to?(:view_collection)

    []
  end

  failure_message do |json_response|
    "expected attributes of #{serializer} serializer to be included in #{json_response}"
  end

  failure_message_when_negated do |json_response|
    "expected attributes of #{serializer} serializer not to be included in #{json_response}"
  end

  description do
    "checks to see if all the serializer's attributes are in the JSON response"
  end

  def all_attributes_included?(attributes, json_response)
    attributes.all? do |attribute|
      json_response.key?(attribute.to_s) || json_response.key?(attribute.to_sym)
    end
  end
end
