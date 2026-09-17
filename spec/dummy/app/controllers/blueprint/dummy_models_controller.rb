# frozen_string_literal: true

module Blueprint
  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end

    SERIALIZER_OPTIONS = -> { { url_builder: self } }

    simple_crud_for :index, serializer: DummyModelBlueprint
    simple_crud_for :show, serializer: DummyModelBlueprint, serializer_options: SERIALIZER_OPTIONS
    simple_crud_for :create, serializer: DummyModelBlueprint, serializer_options: SERIALIZER_OPTIONS
    simple_crud_for :update, serializer: DummyModelBlueprint, serializer_options: SERIALIZER_OPTIONS
    simple_crud_for :destroy, serializer: DummyModelBlueprint, serializer_options: SERIALIZER_OPTIONS
  end
end
