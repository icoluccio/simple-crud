# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/authorization/action_policy_adapter'

class ActionPolicyTestRecord
  attr_reader :owner_id

  def initialize(owner_id)
    @owner_id = owner_id
  end
end

class ActionPolicyTestRecordPolicy < ActionPolicy::Base
  def show?
    user == record.owner_id
  end
end

class ActionPolicyTestController
  include ActionPolicy::Controller
  authorize :user, through: :current_user

  attr_accessor :action_name, :current_user
end

describe SimpleCrud::Authorization::ActionPolicyAdapter do
  subject(:adapter) { described_class.new }

  let(:controller) do
    ActionPolicyTestController.new.tap do |c|
      c.action_name = 'show'
      c.current_user = 1
    end
  end

  describe '#authorize' do
    it 'passes for a record the policy allows' do
      expect { adapter.authorize(controller, ActionPolicyTestRecord.new(1)) }.not_to raise_error
    end

    it 'raises for a record the policy denies' do
      expect do
        adapter.authorize(controller, ActionPolicyTestRecord.new(2))
      end.to raise_error(ActionPolicy::Unauthorized)
    end
  end

  describe '#policy_defined?' do
    it 'is true when a matching policy class exists' do
      expect(adapter.policy_defined?(ActionPolicyTestRecord)).to be true
    end

    it 'is false when no matching policy class exists' do
      expect(adapter.policy_defined?(String)).to be false
    end
  end
end
