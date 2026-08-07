# frozen_string_literal: true

require 'spec_helper'

describe BlockDestroy::DummyModelsController, type: :request do
  include_examples 'simple crud for destroy with block'
end
