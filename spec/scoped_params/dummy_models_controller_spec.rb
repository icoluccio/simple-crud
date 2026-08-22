# frozen_string_literal: true

require 'spec_helper'

describe ScopedParams::DummyModelsController, simple_crud: {
  scoped_attributes: -> { { user: current_user, something: 42 } },
  other_scoped_attributes: -> { { user: other_user, something: 7 } }
}, type: :controller do
  include_examples 'simple crud for index with scope' do
    let(:request_params) { { something: 42 } }
  end
end
