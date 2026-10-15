# frozen_string_literal: true

module BlockPolicyShow
  # The block consults the policy again (as an app picking a page by role would).
  class DummyModelsController < BlockModes::BaseController
    include Pundit::Authorization

    simple_crud_for :show, html: true, authenticate: false do |record|
      render_model(record, :show) if policy(record).update?
    end
  end
end
