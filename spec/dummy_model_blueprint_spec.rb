# frozen_string_literal: true

require 'spec_helper'

describe DummyModelBlueprint do
  let(:dummy_model) { DummyModel.new(id: 3, name: 'widget', something: 'thing', user_id: 7) }
  let(:full_response) { described_class.render_as_hash(dummy_model) }

  it 'matches a response including all blueprint attributes' do
    expect(full_response).to have_been_serialized_with(described_class)
  end

  it 'does not match a response missing blueprint attributes' do
    expect({ 'id' => dummy_model.id }).not_to have_been_serialized_with(described_class)
  end
end
