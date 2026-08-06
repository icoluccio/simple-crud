# frozen_string_literal: true

module Block
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    simple_crud_for :index, paginate: false, authenticate: false, authorize: false do |records|
      render :index, locals: { models: records }
    end
  end
end
