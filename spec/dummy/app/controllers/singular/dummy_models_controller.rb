# frozen_string_literal: true

module Singular
  class DummyModelsController < HtmlModes::BaseController
    FIRST_RECORD = ->(_params) { DummyModel.first! }

    simple_crud_for :show, html: false, authenticate: false, authorize: false, finder: FIRST_RECORD
    simple_crud_for :edit, html: false, authenticate: false, authorize: false, finder: FIRST_RECORD
    simple_crud_for :update, html: false, authenticate: false, authorize: false, finder: FIRST_RECORD
    simple_crud_for :destroy, html: false, authenticate: false, authorize: false, finder: FIRST_RECORD
  end
end
