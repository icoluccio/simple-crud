# frozen_string_literal: true

require 'spec_helper'

describe Singular::DummyModelsController, simple_crud: { singular: true }, type: :controller do
  include_examples 'simple crud for show'
  include_examples 'simple crud for edit'
  include_examples 'simple crud for update'
  include_examples 'simple crud for destroy'
end
