# frozen_string_literal: true

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

  simple_crud_for :create
  simple_crud_for :destroy
  simple_crud_for :update
  simple_crud_for :show
  simple_crud_for :index
end
