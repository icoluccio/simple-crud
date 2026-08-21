# frozen_string_literal: true

require 'spec_helper'

describe BlockCreate::DummyModelsController, type: :controller do
  include_examples 'simple crud for create with block'
end
