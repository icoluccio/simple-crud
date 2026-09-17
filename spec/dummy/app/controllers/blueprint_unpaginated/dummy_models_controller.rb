# frozen_string_literal: true

module BlueprintUnpaginated
  class DummyModelsController < ApplicationController
    include Pundit::Authorization
    extend SimpleCrudController

    simple_crud_for :index, paginate: false, serializer: DummyModelBlueprint
  end
end
