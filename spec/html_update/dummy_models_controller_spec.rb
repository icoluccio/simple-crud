# frozen_string_literal: true

require 'spec_helper'

describe HtmlUpdate::DummyModelsController, type: :controller do
  include_examples 'simple crud for update'
end
