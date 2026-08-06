# frozen_string_literal: true

require 'spec_helper'

describe BlockShow::DummyModelsController, type: :request do
  include_examples 'simple crud for show with block'
end
