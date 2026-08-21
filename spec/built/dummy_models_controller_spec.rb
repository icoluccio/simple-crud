# frozen_string_literal: true

require 'spec_helper'

describe Built::DummyModelsController, type: :controller do
  include_examples 'simple crud for new with build'
  include_examples 'simple crud for create with build'
end
