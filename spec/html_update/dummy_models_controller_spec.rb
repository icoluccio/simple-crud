# frozen_string_literal: true

require 'spec_helper'

describe HtmlUpdate::DummyModelsController, type: :request do
  include_examples 'simple crud for update with html'
end
