# frozen_string_literal: true

module RedirectAuth
  class UnauthenticatedError < StandardError; end

  class DummyModelsController < ApplicationController
    include Wor::Paginate
    include Pundit::Authorization
    extend SimpleCrudController

    rescue_from UnauthenticatedError, with: :redirect_to_login

    def authenticate_user!
      raise UnauthenticatedError unless current_user
    end

    def redirect_to_login(_exception)
      redirect_to '/login'
    end

    simple_crud_for :index, authorize: false
  end
end
