# frozen_string_literal: true

require 'spec_helper'

describe NestedRoute::DummyModelsController, type: :controller do
  let(:model_attributes) { { classroom_slug: 'room-1', user: current_user } }

  around do |example|
    with_config_override(:route_params, -> { { classroom_slug: 'room-1' } }) do
      with_config_override(:params_key, :dummy_model) do
        example.run
      end
    end
  end

  include_examples 'simple crud for show'
  include_examples 'simple crud for create'
  include_examples 'simple crud for destroy'
end
