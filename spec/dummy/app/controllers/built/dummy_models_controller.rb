# frozen_string_literal: true

module Built
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end

    simple_crud_for :new, build: -> { current_user.dummy_models.build }
    simple_crud_for :create, build: -> { current_user.dummy_models.build }
  end
end
