# frozen_string_literal: true

module Nested
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    def dummy_model_params
      params.require(:dummy_model).permit(:name, :something, :user_id, :slug)
    end

    simple_crud_for :create
    simple_crud_for :update
  end
end
