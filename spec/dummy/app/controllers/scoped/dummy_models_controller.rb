# frozen_string_literal: true

module Scoped
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    simple_crud_for :index, scope: ->(user) { DummyModel.where(user: user) }
  end
end
