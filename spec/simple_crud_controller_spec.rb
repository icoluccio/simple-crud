# frozen_string_literal: true

require 'spec_helper'

class UnpoliceableThing; end

class UnpoliceableThingsController
  extend SimpleCrudController
end

describe SimpleCrudController do
  describe '.check_policies' do
    it 'returns when a matching policy exists' do
      expect { DummyModelsController.check_policies(authorize: true) }.not_to raise_error
    end

    it 'raises when no matching policy exists' do
      expect do
        UnpoliceableThingsController.check_policies(authorize: true)
      end.to raise_error(ArgumentError)
    end
  end

  describe '.check_serializer' do
    it 'returns when the serializer option is blank' do
      expect { DummyModelsController.check_serializer({}) }.not_to raise_error
    end

    it 'returns when a matching serializer exists' do
      expect do
        DummyModelsController.check_serializer(serializer: 'DummyModelSerializer')
      end.not_to raise_error
    end

    it 'raises when no matching serializer exists' do
      expect do
        DummyModelsController.check_serializer(serializer: 'NonExistentSerializer')
      end.to raise_error(ArgumentError)
    end
  end
end
