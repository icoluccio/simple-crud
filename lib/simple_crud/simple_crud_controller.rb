# frozen_string_literal: true

require 'active_support/all'
require_relative 'config'
require_relative 'controller_helpers'

# Extended onto a controller for CRUD actions.
module SimpleCrudController
  extend SimpleCrud::ControllerHelpers

  cattr_accessor :params, :permitted

  # Possible options:
  ### authorize: check authorization via Config.authorization_adapter (Pundit by default)
  ### paginate: paginate the list via Config.pagination_adapter (wor-paginate by default)
  ### authenticate: use devise to authenticate
  ### serializer: use a particular serializer (both each_serializer and serializer)
  ### html: render the action's ERB template instead of JSON (index/show/new/create/update/destroy)
  ### finder: custom record lookup (Proc/lambda or Symbol) for :show/:update/:destroy
  ### scope: custom index scope (Proc/lambda taking current_user and optional params), overrides policy_scope
  ### build: custom record builder (Proc/lambda) for :new/:create, invoked with the controller as self
  ### raise_on_invalid: use strict create!/update! semantics instead of returning 422
  ### A block given to simple_crud_for renders explicitly: it receives the records for :index,
  ### the record for :show/:new, or the record and a saved flag for :create/:update/:destroy
  def simple_crud_for(method, parameters = {}, &block)
    parameters = parameters_with_defaults(parameters)
    klass = simple_crud_controller_model
    check_valid_method(method)
    check_policies(parameters)
    check_serializer(parameters)
    define_method(method, send("crud_lambda_for_#{method}", klass, parameters, &block))
    write_metadata(method, parameters)
  end

  def parameters_with_defaults(parameters)
    defaults = {
      authorize: true, paginate: true, authenticate: true, serializer: nil,
      html: false, finder: nil, scope: nil, build: nil, raise_on_invalid: false
    }
    defaults.each { |key, value| parameters[key] = value unless parameters.key?(key) }
    parameters
  end

  def write_metadata(method, parameters)
    @simple_crud_metadata ||= {}
    @simple_crud_metadata[method] = parameters
  end

  def crud_lambda_for_show(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = SimpleCrudController.find_record(klass, self, parameters)

      options = {}.merge(serializer: parameters[:serializer]).compact
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      SimpleCrudController.render_show(self, requested, options, parameters, &block)
    end
  end

  def crud_lambda_for_new(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      record = SimpleCrudController.build_record(self, klass, parameters)
      SimpleCrudController.maybe_authorize(self, record, parameters)
      SimpleCrudController.render_new(self, record, parameters, &block)
    end
  end

  def crud_lambda_for_index(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      SimpleCrudController.maybe_authorize(self, klass.new, parameters)
      options = {}.merge(each_serializer: parameters[:serializer]).compact
      SimpleCrudController.render_index(self, klass, options, parameters, &block)
    end
  end

  def crud_lambda_for_create(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      permitted_params = send("#{self.class.simple_crud_controller_model.to_s.underscore}_params")
      record = SimpleCrudController.build_record(self, klass, parameters)
      record.assign_attributes(permitted_params)
      SimpleCrudController.maybe_authorize(self, record, parameters)
      persist = ->(bang:) { bang ? record.save! : record.save }
      options = { status: :created, failure_template: :new }
      SimpleCrudController.save_and_render(self, record, parameters, options, persist, &block)
    end
  end

  def crud_lambda_for_update(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = SimpleCrudController.find_record(klass, self, parameters)
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      permitted_params = send("#{self.class.simple_crud_controller_model.to_s.underscore}_params")
      persist = ->(bang:) { bang ? requested.update!(permitted_params) : requested.update(permitted_params) }
      options = { status: :ok, failure_template: :edit }
      SimpleCrudController.save_and_render(self, requested, parameters, options, persist, &block)
    end
  end

  def crud_lambda_for_destroy(klass, parameters = {}, &block)
    lambda do
      authenticate_user! if parameters[:authenticate]
      requested = SimpleCrudController.find_record(klass, self, parameters)
      SimpleCrudController.maybe_authorize(self, requested, parameters)
      options = { status: :ok, failure_template: :show, redirect: klass }
      persist = ->(bang:) { bang ? requested.destroy! : requested.destroy }
      SimpleCrudController.persist_and_render(self, requested, parameters, options, persist, &block)
    end
  end

  def simple_crud_controller_model
    to_s.split('::').last.sub('Controller', '').singularize.classify.constantize
  end

  def check_valid_method(method)
    throw 'invalid method' unless %i[show index create update destroy new].include? method
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
