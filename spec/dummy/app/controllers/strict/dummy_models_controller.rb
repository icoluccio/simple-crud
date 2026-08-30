# frozen_string_literal: true

module Strict
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end

    simple_crud_for :create, raise_on_invalid: true
    simple_crud_for :update, raise_on_invalid: true
  end
end
