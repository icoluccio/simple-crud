# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/authorization/can_can_can_adapter'

class CanCanCanTestRecord
  attr_reader :owner_id

  def initialize(owner_id)
    @owner_id = owner_id
  end
end

class Ability
  include CanCan::Ability

  def initialize(user_id)
    can :manage, CanCanCanTestRecord, owner_id: user_id
  end
end

class CanCanCanTestController
  include CanCan::ControllerAdditions

  attr_accessor :action_name, :current_user
end

describe SimpleCrud::Authorization::CanCanCanAdapter do
  subject(:adapter) { described_class.new }

  let(:controller) do
    CanCanCanTestController.new.tap do |c|
      c.action_name = 'show'
      c.current_user = 1
    end
  end

  describe '#authorize' do
    include_examples 'authorization adapter #authorize', CanCanCanTestRecord, CanCan::AccessDenied
  end

  describe '#policy_defined?' do
    it 'is true when an Ability class exists' do
      expect(adapter.policy_defined?(CanCanCanTestRecord)).to be true
    end
  end
end
