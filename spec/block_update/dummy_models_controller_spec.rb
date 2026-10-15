# frozen_string_literal: true

require 'spec_helper'

describe BlockUpdate::DummyModelsController, type: :controller do
  include_examples 'simple crud for update with block'

  describe 'without a validated attribute', simple_crud: { required_attribute: nil } do
    include_examples 'simple crud for update with block'
  end
end
