# frozen_string_literal: true

module HtmlNotice
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :create, html: true, authenticate: false, authorize: false,
                             notice: 'created', alert: 'invalid'
    simple_crud_for :update, html: true, authenticate: false, authorize: false,
                             notice: 'updated', alert: 'invalid'
    simple_crud_for :destroy, html: true, authenticate: false, authorize: false, notice: 'removed'
  end
end
