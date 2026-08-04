# frozen_string_literal: true

require 'active_support/all'
require_relative 'config'

# Extended onto a controller to generate CRUD actions from one declarative call.
module SimpleCrudController
  cattr_accessor :params, :permitted

  # Possible options:
  ### authorize: check authorization via Config.authorization_adapter (Pundit by default)
  ### paginate: paginate the list via Config.pagination_adapter (wor-paginate by default)
  ### authenticate: use devise to authenticate
  ### serializer: use a particular serializer (both each_serializer and serializer)
  def simple_crud_for(method, parameters = {})
    parameters = parameters_with_defaults(parameters)
    klass = simple_crud_controller_model
    check_valid_method(method)
    check_policies(parameters)
    check_serializer(parameters)
    define_method(method, send("crud_lambda_for_#{method}", klass, parameters))
    write_metadata(method, parameters)
  end

  def parameters_with_defaults(parameters)
    defaults = { authorize: true, paginate: true, authenticate: true, serializer: nil }
    defaults.each do |key, value|
      parameters[key] = value unless parameters.key?(key)
    end
    parameters
  end

  def write_metadata(method, parameters)
    @simple_crud_metadata ||= {}
    @simple_crud_metadata[method] = parameters
  end

  def self.maybe_authorize(controller, record, parameters)
    return unless parameters[:authorize] && parameters[:authenticate]

    SimpleCrud::Config.authorization_adapter.authorize(controller, record)
  end

  def crud_lambda_for_show(klass, parameters = {})
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = klass.find(params[:id])

      options = {}.merge(serializer: parameters[:serializer]).compact
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      render({ json: requested }.merge(options))
    end
  end

  def crud_lambda_for_index(klass, parameters = {})
    lambda do
      authenticate_user! if parameters[:authenticate]
      SimpleCrudController.maybe_authorize(self, klass.new, parameters)
      options = {}.merge(each_serializer: parameters[:serializer]).compact
      SimpleCrudController.render_index(self, klass, options, parameters)
    end
  end

  def self.render_index(controller, klass, options, parameters)
    if parameters[:paginate]
      SimpleCrud::Config.pagination_adapter.paginate(controller, klass, options)
    else
      controller.render({ json: klass.all }.merge(options))
    end
  end

  def crud_lambda_for_create(klass, parameters = {})
    lambda do
      authenticate_user! if parameters[:authenticate]
      permitted_params = send("#{self.class.simple_crud_controller_model.to_s.underscore}_params")
      SimpleCrudController.maybe_authorize(self, klass.new(permitted_params), parameters)
      render json: klass.create!(permitted_params), status: :created
    end
  end

  def crud_lambda_for_update(klass, parameters = {})
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = klass.find(params[:id])
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      permitted_params = send("#{self.class.simple_crud_controller_model.to_s.underscore}_params")
      render json: requested.update!(permitted_params)
    end
  end

  def crud_lambda_for_destroy(klass, parameters = {})
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = klass.find(params[:id])
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      render json: klass.find(params[:id]).destroy
    end
  end

  def simple_crud_controller_model
    to_s.split('::').last.sub('Controller', '').singularize.classify.constantize
  end

  def check_valid_method(method)
    throw 'invalid method' unless %i[show index create update destroy].include? method
  end

  def check_policies(parameters)
    return if !parameters.key?(:authorize) || !parameters[:authorize]

    model = simple_crud_controller_model
    return if SimpleCrud::Config.authorization_adapter.policy_defined?(model)

    throw "no authorization policy configured for #{model}"
  end

  def check_serializer(parameters)
    return if parameters[:serializer].blank?

    serializer_name = parameters[:serializer].to_s
    return if Kernel.const_defined?(serializer_name)

    throw "create a valid serializer with name #{serializer_name}"
  end
end
