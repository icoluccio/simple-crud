# frozen_string_literal: true

require 'spec_helper'

describe DummyModelPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:dummy_model) { create(:dummy_model, user: user) }

  %i[destroy? index?].each do |policy_method|
    describe "##{policy_method}" do
      it 'allows the owning user' do
        expect(described_class.new(user, dummy_model).public_send(policy_method)).to be true
      end

      it 'denies a different user' do
        expect(described_class.new(other_user, dummy_model).public_send(policy_method)).to be false
      end
    end
  end
end
