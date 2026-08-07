# frozen_string_literal: true

module Strict
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end

    simple_crud_for :create, raise_on_invalid: true
    simple_crud_for :update, raise_on_invalid: true
  end
end
