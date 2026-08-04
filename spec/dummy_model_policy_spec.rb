# frozen_string_literal: true

require 'spec_helper'

describe DummyModelPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:dummy_model) { create(:dummy_model, user: user) }

  describe '#destroy?' do
    it 'allows the owning user' do
      expect(described_class.new(user, dummy_model).destroy?).to be true
    end

    it 'denies a different user' do
      expect(described_class.new(other_user, dummy_model).destroy?).to be false
    end
  end

  describe '#index?' do
    it 'allows the owning user' do
      expect(described_class.new(user, dummy_model).index?).to be true
    end

    it 'denies a different user' do
      expect(described_class.new(other_user, dummy_model).index?).to be false
    end
  end
end
