# frozen_string_literal: true

module InvalidStatus
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: true, authenticate: false, authorize: false do |record, saved|
      if saved
        redirect_to(record)
      else
        render :new, status: 422
      end
    end
  end
end
