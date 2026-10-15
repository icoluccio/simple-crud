# frozen_string_literal: true

module BlockUpdate
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :update, html: false, authenticate: false, authorize: false do |_record, saved|
      render json: { updated: saved }
    end
  end
end
