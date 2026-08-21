# frozen_string_literal: true

module Redirect
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: true, authenticate: false, authorize: false,
                             redirect: ->(_record) { dummy_models_path }
    simple_crud_for :destroy, html: true, authenticate: false, authorize: false,
                              redirect: '/block_new/dummy_models/new'
  end
end
