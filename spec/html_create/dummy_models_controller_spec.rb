# frozen_string_literal: true

require 'spec_helper'

describe HtmlCreate::DummyModelsController, type: :request do
  include_examples 'simple crud for create with html'
end
