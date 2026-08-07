# frozen_string_literal: true

require 'spec_helper'

describe HtmlDestroy::DummyModelsController, type: :request do
  include_examples 'simple crud for destroy with html'
end
