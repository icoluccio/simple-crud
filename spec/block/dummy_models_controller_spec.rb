# frozen_string_literal: true

require 'spec_helper'

describe Block::DummyModelsController, type: :request do
  include_examples 'simple crud for index with block'
end
