# frozen_string_literal: true

module HtmlModes
  class BaseController < ApplicationController
    include Wor::Paginate
    extend SimpleCrudController

    before_action :set_params
    def set_params
      SimpleCrudController.params = params
    end

    def dummy_model_params
      params.permit(:name, :something, :user_id, :slug)
    end
  end
end
