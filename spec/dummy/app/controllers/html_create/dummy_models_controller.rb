# frozen_string_literal: true

module HtmlCreate
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: true, authenticate: false, authorize: false
  end
end
