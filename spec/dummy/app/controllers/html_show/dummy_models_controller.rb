# frozen_string_literal: true

module HtmlShow
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :show, html: true, authenticate: false, authorize: false
  end
end
