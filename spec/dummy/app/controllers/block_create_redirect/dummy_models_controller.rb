# frozen_string_literal: true

module BlockCreateRedirect
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: true, authenticate: false, authorize: false do |record, saved|
      if saved
        redirect_to action: :show, id: record.id
      else
        render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
