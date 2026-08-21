# frozen_string_literal: true

module BlockRedirect
  class DummyModelsController < HtmlModes::BaseController
    simple_crud_for :destroy, authenticate: false, authorize: false do |_record, destroyed|
      if destroyed
        redirect_to action: :show, notice: 'removed'
      else
        redirect_to action: :show, alert: 'could not remove'
      end
    end
  end
end
