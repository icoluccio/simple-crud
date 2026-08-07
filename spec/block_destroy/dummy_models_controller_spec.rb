# frozen_string_literal: true

require 'spec_helper'

describe BlockDestroy::DummyModelsController, type: :controller do
  include_examples 'simple crud for destroy with block'
end
