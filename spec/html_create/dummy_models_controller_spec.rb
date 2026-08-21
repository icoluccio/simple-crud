# frozen_string_literal: true

require 'spec_helper'

describe HtmlCreate::DummyModelsController, type: :controller do
  include_examples 'simple crud for create'
end
