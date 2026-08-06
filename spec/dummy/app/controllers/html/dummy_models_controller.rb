# frozen_string_literal: true

module Html
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    simple_crud_for :index, html: true, authenticate: false, authorize: false
  end
end
