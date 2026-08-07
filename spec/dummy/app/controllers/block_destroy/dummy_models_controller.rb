# frozen_string_literal: true

module BlockDestroy
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :destroy, html: false, authenticate: false, authorize: false do |_record, destroyed|
      render json: { destroyed: destroyed ? true : false }
    end
  end
end
