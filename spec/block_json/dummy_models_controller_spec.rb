# frozen_string_literal: true

require 'spec_helper'

describe BlockJson::DummyModelsController, type: :controller do
  include_examples 'simple crud for index with block'
  include_examples 'simple crud for show with block'
  include_examples 'simple crud for new with block'
end
