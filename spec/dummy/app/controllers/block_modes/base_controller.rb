# frozen_string_literal: true

module BlockModes
  class BaseController < HtmlModes::BaseController
    private

    def render_model(record, template)
      render template, locals: { model: record }
    end
  end
end
