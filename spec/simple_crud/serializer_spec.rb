# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::Serializer do
  let(:record) { DummyModel.new(id: 1, name: 'widget', something: 'thing', user_id: 9) }
  let(:non_class_serializer) do
    Module.new do
      def self.render(_record, **)
        :plain
      end

      def self.new(*)
        Struct.new(:as_json).new(:ams)
      end
    end
  end

  describe '.render' do
    it 'falls back to the record as_json when there is no serializer' do
      expect(described_class.render(nil, record)).to eq(record.as_json)
    end

    it 'renders through a Blueprinter blueprint with the given options' do
      result = described_class.render(DummyModelBlueprint, record, { url_builder: nil })

      expect(result).to include(id: record.id, name: record.name, something: record.something, user_id: record.user_id)
    end

    it 'calls a plain class .render method with the options splatted as keywords' do
      result = described_class.render(DummyModelPlainSerializer, record, { root: false })

      expect(result).to eq(id: record.id, name: record.name, something: record.something, root: false)
    end

    it 'falls through to the AMS path for a non-class that responds to render' do
      expect(described_class.render(non_class_serializer, record)).to eq(:ams)
    end

    it 'instantiates an AMS-style serializer with the given options', :aggregate_failures do
      allow(DummyModelSerializer).to receive(:new).and_call_original

      result = described_class.render(DummyModelSerializer, record, { root: false })

      expect(DummyModelSerializer).to have_received(:new).with(record, { root: false })
      expect(result).to include(id: record.id, something: record.something)
    end
  end
end
