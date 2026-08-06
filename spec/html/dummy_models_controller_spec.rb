# frozen_string_literal: true

require 'spec_helper'

describe Html::DummyModelsController, type: :request do
  include_examples 'simple crud for index with html'
end
