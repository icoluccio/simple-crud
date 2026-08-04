# frozen_string_literal: true

require 'spec_helper'

describe DummyModelSerializer do
  let(:user) { create(:user) }
  let(:dummy_model) { create(:dummy_model, user: user) }
  let(:full_response) { { 'id' => dummy_model.id, 'something' => dummy_model.something, 'user_id' => user.id } }

  it 'matches a response including all serializer attributes' do
    expect(full_response).to have_been_serialized_with(described_class)
  end

  it 'does not match a response missing serializer attributes' do
    expect({ 'id' => dummy_model.id }).not_to have_been_serialized_with(described_class)
  end

  it 'describes itself' do
    expect(have_been_serialized_with(described_class).description)
      .to eq("checks to see if all the serializer's attributes are in the JSON response")
  end

  it 'produces a failure message when it does not match' do
    matcher = have_been_serialized_with(described_class)
    matcher.matches?({ 'id' => dummy_model.id })

    expect(matcher.failure_message).to match(/expected attributes of/)
  end

  it 'produces a negated failure message when it matches but was expected not to' do
    matcher = have_been_serialized_with(described_class)
    matcher.matches?(full_response)

    expect(matcher.failure_message_when_negated).to match(/not to be included in/)
  end
end
