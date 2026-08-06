# frozen_string_literal: true

module HtmlUpdate
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :update, html: true, authenticate: false, authorize: false
  end
end
