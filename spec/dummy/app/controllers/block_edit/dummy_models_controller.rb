# frozen_string_literal: true

module BlockEdit
  class DummyModelsController < BlockModes::BaseController
    simple_crud_for :edit, html: true, authenticate: false, authorize: false do |record|
      render_model(record, :edit)
    end
  end
end
