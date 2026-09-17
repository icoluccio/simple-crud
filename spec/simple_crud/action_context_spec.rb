# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::ActionContext do
  let(:ctx) { described_class.new(double, double, {}) }

  it 'raises NotImplementedError when run is not overridden' do
    expect { ctx.send(:run) }.to raise_error(NotImplementedError)
  end

  it 'raises NotImplementedError when action_name is not overridden' do
    expect { ctx.send(:action_name) }.to raise_error(NotImplementedError)
  end

  describe '.cache_key_for' do
    it 'builds the standard cache key' do
      key = described_class.cache_key_for(DummyModel, :show, '/dummy_models/1')
      expect(key).to eq('dummy_model:show:v1:/dummy_models/1')
    end
  end

  describe '#serializer_options' do
    let(:record) { DummyModel.new(name: 'widget') }

    it 'returns an empty hash when no callable is configured' do
      ctx = described_class.new(double, DummyModel, {})
      expect(ctx.send(:serializer_options, record)).to eq({})
    end

    it 'calls a zero-arity callable without the record' do
      ctx = described_class.new(double, DummyModel, { serializer_options: -> { { prefix: :none } } })
      expect(ctx.send(:serializer_options, record)).to eq(prefix: :none)
    end

    it 'calls an arity-one callable with the record' do
      ctx = described_class.new(double, DummyModel, { serializer_options: ->(record) { { name: record.name } } })
      expect(ctx.send(:serializer_options, record)).to eq(name: 'widget')
    end
  end
end
