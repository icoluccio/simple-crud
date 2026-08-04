# frozen_string_literal: true

module WithoutPagination
  class DummyModelsController < ApplicationController
    include Pundit::Authorization
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    simple_crud_for :index, paginate: false
  end
end
