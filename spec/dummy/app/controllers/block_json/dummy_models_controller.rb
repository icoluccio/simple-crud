# frozen_string_literal: true

module BlockJson
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :index, html: false, authenticate: false, authorize: false, paginate: false do |records|
      render json: { ids: records.map(&:id) }
    end

    simple_crud_for :show, html: false, authenticate: false, authorize: false do |record|
      render json: { id: record.id }
    end

    simple_crud_for :new, html: false, authenticate: false, authorize: false do |record|
      render json: { id: record.id }
    end
  end
end
