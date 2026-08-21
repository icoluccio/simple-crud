# frozen_string_literal: true

require 'spec_helper'

describe BlockRedirect::DummyModelsController, type: :controller do
  include_examples 'simple crud for destroy'
end
