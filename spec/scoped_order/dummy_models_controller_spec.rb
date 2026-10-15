# frozen_string_literal: true

require 'spec_helper'

describe ScopedOrder::DummyModelsController, simple_crud: {
  other_scoped_attributes: nil,
  scoped_order: ->(records) { records.sort_by { |r| [r.name, r.id] } }
}, type: :controller do
  include_examples 'simple crud for index with scope'
end
