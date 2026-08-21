# frozen_string_literal: true

require 'spec_helper'

describe BlockNew::DummyModelsController, type: :controller do
  include_examples 'simple crud for new with block'
end
