# frozen_string_literal: true

module BlockShow
  class DummyModelsController < BlockModes::BaseController
    simple_crud_for :show, authenticate: false, authorize: false do |record|
      render_model(record, :show)
    end
  end
end
