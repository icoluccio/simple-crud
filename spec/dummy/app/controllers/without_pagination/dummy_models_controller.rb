# frozen_string_literal: true

module WithoutPagination
  class DummyModelsController < ApplicationController
    include Pundit::Authorization
    extend SimpleCrudController

    simple_crud_for :index, paginate: false
  end
end
