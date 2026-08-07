# frozen_string_literal: true

require 'spec_helper'

describe Block::DummyModelsController, type: :controller do
  include_examples 'simple crud for index with block'
  include_examples 'simple crud for index'
end
