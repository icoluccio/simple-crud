# frozen_string_literal: true

module ScopedOrder
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    simple_crud_for :index, scope: ->(_user) { DummyModel.order(:name, :id) }, authorize: false
  end
end
