# frozen_string_literal: true

require 'spec_helper'

describe HtmlNew::DummyModelsController, type: :request do
  include_examples 'simple crud for new with html'
end
