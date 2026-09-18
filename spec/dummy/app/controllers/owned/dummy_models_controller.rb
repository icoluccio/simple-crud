# frozen_string_literal: true

module Owned
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    # No :user_id: a permitted FK would let a request override the owner set by owned_by:.
    def dummy_model_params
      params.permit(:name, :something, :slug)
    end

    simple_crud_defaults owned_by: :dummy_models, authorize: false
    simple_crud_for :index
    simple_crud_for :show
    simple_crud_for :create
    simple_crud_for :update
    simple_crud_for :destroy
  end
end
