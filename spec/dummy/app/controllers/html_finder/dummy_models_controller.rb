# frozen_string_literal: true

module HtmlFinder
  class DummyModelsController < HtmlModes::BaseController
    include Pundit::Authorization

    simple_crud_for :show, html: true, authenticate: false, authorize: false,
                           finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) }
    simple_crud_for :update, html: true, authenticate: false, authorize: false,
                             finder: :find_by_slug
    simple_crud_for :destroy, html: true, authenticate: false, authorize: false,
                              finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) }
    simple_crud_for :new, html: true, build: -> { current_user.dummy_models.build }
    simple_crud_for :edit, html: true, authenticate: false, authorize: false,
                           finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) }
  end
end
