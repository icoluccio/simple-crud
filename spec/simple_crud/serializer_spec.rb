# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::Serializer do
  let(:record) { DummyModel.new(id: 1, name: 'widget', something: 'thing', user_id: 9) }

  describe '.render' do
    it 'falls back to the record as_json when there is no serializer' do
      expect(described_class.render(nil, record)).to eq(record.as_json)
    end

    it 'renders through a Blueprinter blueprint with the given options' do
      result = described_class.render(DummyModelBlueprint, record, { url_builder: nil })

      expect(result).to include(id: record.id, name: record.name, something: record.something, user_id: record.user_id)
    end

    it 'instantiates an AMS-style serializer with the given options', :aggregate_failures do
      allow(DummyModelSerializer).to receive(:new).and_call_original

      result = described_class.render(DummyModelSerializer, record, { root: false })

      expect(DummyModelSerializer).to have_received(:new).with(record, { root: false })
      expect(result).to include(id: record.id, something: record.something)
    end
  end
end
