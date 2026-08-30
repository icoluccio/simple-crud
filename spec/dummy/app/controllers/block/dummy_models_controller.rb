# frozen_string_literal: true

module Block
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    extend SimpleCrudController

    simple_crud_for :index, html: true, paginate: false, authenticate: false, authorize: false do |records|
      render :index, locals: { models: records }
    end
  end
end
