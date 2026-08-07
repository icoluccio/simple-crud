# frozen_string_literal: true

module Html
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :index, html: true, authenticate: false, authorize: false
  end
end
