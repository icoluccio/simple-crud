# frozen_string_literal: true

module CachedDefaults
  class DummyModelsController < ApplicationController
    extend SimpleCrudController
    simple_crud_defaults authorize: false, authenticate: false

    simple_crud_for :show, cache: {}
    simple_crud_for :index, paginate: false, cache: {}
  end
end
