# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::IndexContext do
  describe '#call_scope' do
    after { SimpleCrud::Config.user_method = :current_user }

    let(:controller) { double(params: { status: 'active' }) }

    it 'passes nil when controller has no current_user' do
      scope = ->(u) { u ? :scoped : :unscoped }
      ctx = described_class.new(controller, DummyModel, { scope: scope, authorize: false })
      expect(ctx.send(:call_scope)).to eq(:unscoped)
    end

    it 'passes params as second arg when scope has arity 2' do
      scope = ->(u, p) { [u, p[:status]] }
      ctx = described_class.new(controller, DummyModel, { scope: scope, authorize: false })
      expect(ctx.send(:call_scope)).to eq([nil, 'active'])
    end

    it 'resolves user via overridden Config.user_method' do
      SimpleCrud::Config.user_method = :current_admin
      admin = double
      ctrl = double(params: {}, current_admin: admin)
      ctx = described_class.new(ctrl, DummyModel, { scope: ->(u) { u }, authorize: false })
      expect(ctx.send(:call_scope)).to eq(admin)
    end

    it 'runs an arity-zero scope with the controller as self and no arguments' do
      ctrl = double(params: {}, listing: DummyModel.none)
      ctx = described_class.new(ctrl, DummyModel, { scope: -> { listing }, authorize: false })

      expect(ctx.send(:call_scope)).to eq(DummyModel.none)
    end

    it 'dispatches a Symbol scope to the model with user and params' do
      ctrl = double(params: { status: 'active' })
      allow(DummyModel).to receive(:visible_to).with(nil, { status: 'active' }).and_return(DummyModel.none)
      ctx = described_class.new(ctrl, DummyModel, { scope: :visible_to, authorize: false })

      expect(ctx.send(:call_scope)).to eq(DummyModel.none)
    end
  end

  describe '#index_relation' do
    let(:owned_records) { DummyModel.none }

    it 'scopes to the owned_by relation even when authorize is on' do
      ctrl = double(params: {}, current_user: double(dummy_models: owned_records))
      ctx = described_class.new(ctrl, DummyModel, { owned_by: :dummy_models, authorize: true })

      expect(ctx.send(:index_relation)).to eq(owned_records)
    end

    it 'returns no records when there is no user to own them' do
      ctx = described_class.new(double(params: {}), DummyModel, { owned_by: :dummy_models, authorize: false })

      expect(ctx.send(:index_relation)).to be_empty
    end

    it 'scopes to the parent relation' do
      parent = double(dummy_models: owned_records)
      ctrl = double(params: {})
      ctrl.instance_variable_set(:@owner, parent)
      ctx = described_class.new(ctrl, DummyModel, { parent: :owner, authorize: false })

      expect(ctx.send(:index_relation)).to eq(owned_records)
    end

    it 'returns no records when the parent association is empty' do
      ctrl = double(params: {})
      ctrl.instance_variable_set(:@owner, double(dummy_models: nil))
      ctx = described_class.new(ctrl, DummyModel, { parent: :owner, authorize: false })

      expect(ctx.send(:index_relation)).to be_empty
    end
  end
end
