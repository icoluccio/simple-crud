# frozen_string_literal: true

module HtmlNew
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :new, html: true, authenticate: false, authorize: false
  end
end
