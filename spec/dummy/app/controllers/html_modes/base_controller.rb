# frozen_string_literal: true

module HtmlModes
  class BaseController < ApplicationController
    include Wor::Paginate
    extend SimpleCrudController

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end
  end
end
