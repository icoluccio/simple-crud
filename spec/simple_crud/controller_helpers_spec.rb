# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/controller_helpers'

describe SimpleCrud::ControllerHelpers do
  subject(:helpers) do
    Class.new do
      extend SimpleCrud::ControllerHelpers
    end
  end

  describe '.call_scope' do
    after { SimpleCrud::Config.user_method = :current_user }

    it 'passes nil as the user when the controller has no current_user' do
      controller = double(params: { status: 'active' })
      scope = ->(user) { user ? :scoped_to_user : :unscoped }

      expect(helpers.call_scope(scope, controller)).to eq(:unscoped)
    end

    it 'still passes params as the second argument when the scope takes two' do
      controller = double(params: { status: 'active' })
      scope = ->(user, params) { [user, params[:status]] }

      expect(helpers.call_scope(scope, controller)).to eq([nil, 'active'])
    end

    it 'resolves the user via Config.user_method when overridden' do
      SimpleCrud::Config.user_method = :current_admin
      admin = double
      controller = double(params: {}, current_admin: admin)
      scope = ->(user) { user }

      expect(helpers.call_scope(scope, controller)).to eq(admin)
    end
  end

  describe '.find_record' do
    it 'raises when a custom finder returns something other than a record' do
      controller = double(params: {})
      parameters = { finder: ->(_params) { DummyModel.where(name: 'x') } }

      expect { helpers.find_record(DummyModel, controller, parameters) }
        .to raise_error(ActiveRecord::RecordNotFound, /must return a single record/)
    end
  end
end
