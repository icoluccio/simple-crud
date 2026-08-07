# frozen_string_literal: true

module BlockCreate
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: false, authenticate: false, authorize: false do |record, saved|
      if saved
        render json: { saved: true, id: record.id }
      else
        render json: { saved: false, errors: record.errors.full_messages }, status: 422
      end
    end
  end
end
