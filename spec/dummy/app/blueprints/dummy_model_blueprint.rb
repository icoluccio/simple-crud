# frozen_string_literal: true

class DummyModelBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :something, :user_id

  field :url do |record, options|
    options[:url_builder]&.dummy_model_url(record)
  end
end
