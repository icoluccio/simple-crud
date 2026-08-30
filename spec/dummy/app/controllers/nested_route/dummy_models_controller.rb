# frozen_string_literal: true

module NestedRoute
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    def dummy_model_params
      params.require(:dummy_model).permit(:name, :something, :user_id, :slug, :classroom_slug)
    end

    NESTED_FINDER = lambda do |params|
      DummyModel.find_by!(classroom_slug: params[:classroom_slug], slug: params[:slug])
    end

    simple_crud_for :show, finder: NESTED_FINDER
    simple_crud_for :destroy, finder: NESTED_FINDER
    simple_crud_for :create
  end
end
