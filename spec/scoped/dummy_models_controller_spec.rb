# frozen_string_literal: true

require 'spec_helper'

describe Scoped::DummyModelsController, type: :controller do
  include_examples 'simple crud for index with scope'
end
