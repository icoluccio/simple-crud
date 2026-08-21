# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/authorization/pundit_adapter'

class PolicyScopeTestModel; end

class PolicyScopeTestModelPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      :scoped
    end
  end
end

class PolicyScopeTestController
  include Pundit::Authorization

  attr_accessor :current_user
end

describe SimpleCrud::Authorization::PunditAdapter do
  subject(:adapter) { described_class.new }

  let(:controller) { PolicyScopeTestController.new.tap { |c| c.current_user = :user } }

  describe '#policy_scope' do
    it 'returns the resolved policy scope when one is defined' do
      expect(adapter.policy_scope(controller, PolicyScopeTestModel)).to eq(:scoped)
    end

    it 'falls back to the full relation when no scope is defined' do
      expect(adapter.policy_scope(controller, DummyModel).to_sql).to eq(DummyModel.all.to_sql)
    end
  end
end
