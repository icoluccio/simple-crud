# frozen_string_literal: true

require 'pagy'

class ApplicationController < ActionController::Base
  # :unprocessable_entity was renamed :unprocessable_content in Rack 3.1;
  # older Rack (bundled with Rails 6.1/7.0) doesn't recognize the new name.
  UNPROCESSABLE_STATUS = if Rack::Utils::SYMBOL_TO_STATUS_CODE.key?(:unprocessable_content)
                           :unprocessable_content
                         else
                           :unprocessable_entity
                         end

  protect_from_forgery with: :exception
  include Wor::Paginate
  include Pagy::Method
  include ActionController::MimeResponds
  respond_to :json
  # i18n configuration. See: http://guides.rubyonrails.org/i18n.html
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::StatementInvalid, with: :unprocessable
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
  rescue_from ActionController::ParameterMissing, with: :unprocessable
  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  # TODO: find a less general way to catch wrong enum values
  rescue_from ArgumentError, with: :unprocessable
  def not_found(_exception)
    head :not_found
  end

  def unprocessable(exception)
    render json: { errors: exception }, status: UNPROCESSABLE_STATUS
  end

  def forbidden(exception)
    render json: { errors: exception }, status: :forbidden
  end
end
