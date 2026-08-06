# frozen_string_literal: true

require 'spec_helper'

describe HtmlShow::DummyModelsController, type: :request do
  include_examples 'simple crud for show with html'
end
