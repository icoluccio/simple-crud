# frozen_string_literal: true

module ScopedSymbol
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    simple_crud_for :index, scope: :visible_to
  end
end
