# frozen_string_literal: true

require 'spec_helper'

describe RedirectAuth::DummyModelsController, type: :controller do
  around do |example|
    with_config_override(:unauthenticated_status, :found) { example.run }
  end

  include_examples 'simple crud for index'
end
