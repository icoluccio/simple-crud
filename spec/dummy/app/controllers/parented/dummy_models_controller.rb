# frozen_string_literal: true

module Parented
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    # The default association for this model is @user.dummy_models.
    def owner = @owner ||= User.find(params[:owner_id])

    def dummy_model_params
      params.permit(:name, :something, :slug)
    end

    simple_crud_defaults parent: :owner, authorize: false
    simple_crud_for :index
    simple_crud_for :show
    simple_crud_for :create
    simple_crud_for :update
    simple_crud_for :destroy
  end
end
