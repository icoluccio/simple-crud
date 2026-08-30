# frozen_string_literal: true

module BlockNew
  class DummyModelsController < BlockModes::BaseController
    simple_crud_for :new, html: true, authenticate: false, authorize: false do |record|
      render_model(record, :new)
    end
  end
end
