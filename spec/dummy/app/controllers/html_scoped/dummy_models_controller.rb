# frozen_string_literal: true

module HtmlScoped
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :index, html: true, scope: ->(user) { DummyModel.where(user: user) },
                            authenticate: false, authorize: false
  end
end
