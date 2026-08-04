# frozen_string_literal: true

require_relative 'dummy_model_policy'
class DummyModel < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
end
