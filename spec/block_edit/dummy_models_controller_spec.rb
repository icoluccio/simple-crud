# frozen_string_literal: true

require 'spec_helper'

describe BlockEdit::DummyModelsController, type: :controller do
  include_examples 'simple crud for edit with block'
end
