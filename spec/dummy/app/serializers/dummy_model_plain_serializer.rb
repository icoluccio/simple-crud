# frozen_string_literal: true

# Exercises the plain-class serializer path.
class DummyModelPlainSerializer
  def self.render(record, **options)
    { id: record.id, name: record.name, something: record.something, root: options[:root] }.compact
  end
end
