# frozen_string_literal: true

require 'spec_helper'

describe BlueprintUnpaginated::DummyModelsController, type: :controller do
  let(:serializer) { DummyModelBlueprint }

  include_examples 'simple crud for index'
end
