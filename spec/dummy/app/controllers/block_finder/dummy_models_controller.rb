# frozen_string_literal: true

module BlockFinder
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :show, html: false, authenticate: false, authorize: false,
                           finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) } do |record|
      render json: { found_id: record.id }
    end

    simple_crud_for :update, html: false, authenticate: false, authorize: false,
                             finder: :find_by_slug do |_record, saved|
      render json: { updated: saved }
    end

    simple_crud_for :destroy, html: false, authenticate: false, authorize: false,
                              finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) } do |_record, destroyed|
      render json: { destroyed: destroyed }
    end

    simple_crud_for :edit, html: false, authenticate: false, authorize: false,
                           finder: ->(params) { DummyModel.find_by!(slug: params[:slug]) } do |record|
      render json: { edit_id: record.id }
    end
  end
end
