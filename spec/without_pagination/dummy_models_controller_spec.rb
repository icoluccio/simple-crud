# frozen_string_literal: true

require 'spec_helper'
describe WithoutPagination::DummyModelsController, type: :controller do
  include_examples 'simple crud for index'
end
