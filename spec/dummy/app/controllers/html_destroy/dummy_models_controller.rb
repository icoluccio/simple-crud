# frozen_string_literal: true

module HtmlDestroy
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :destroy, html: true, authenticate: false, authorize: false
  end
end
