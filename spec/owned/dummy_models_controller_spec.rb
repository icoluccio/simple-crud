# frozen_string_literal: true

require 'spec_helper'

describe Owned::DummyModelsController, type: :controller do
  include_examples 'simple crud for show'
  include_examples 'simple crud for create'
  include_examples 'simple crud for update'
  include_examples 'simple crud for destroy'
  include_examples 'simple crud for index'
  include_examples 'simple crud for owned resource'
end
