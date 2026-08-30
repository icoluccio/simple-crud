# frozen_string_literal: true

module Scoped
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    simple_crud_for :index, scope: ->(user) { DummyModel.where(user: user) }
  end
end
