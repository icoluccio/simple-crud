# frozen_string_literal: true

module Finder
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    def dummy_model_params
      params.permit(:name, :something, :user_id)
    end

    simple_crud_for :show, finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) }
    simple_crud_for :update, finder: :find_by_slug
    simple_crud_for :destroy, finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) }
  end
end
