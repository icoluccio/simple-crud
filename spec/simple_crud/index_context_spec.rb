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
  end
end
