# frozen_string_literal: true

require 'active_support/all'
require_relative 'config'
require_relative 'cache_helpers'
require_relative 'action_context'
require_relative 'form_context'
require_relative 'persistence_context'
require_relative 'show_context'
require_relative 'index_context'
require_relative 'new_context'
require_relative 'edit_context'
require_relative 'create_context'
require_relative 'update_context'
require_relative 'destroy_context'
require_relative 'action_lambdas'

# Extended onto a controller for CRUD actions.
module SimpleCrudController
  include SimpleCrud::ActionLambdas

  def self.extended(base)
    base.include(SimpleCrud::CacheHelpers)
  end

  # Possible options:
  ### authorize: check authorization via Config.authorization_adapter (Pundit by default)
  ### paginate: paginate the list via Config.pagination_adapter (wor-paginate by default)
  ### authenticate: true calls authenticate_user! inside the action lambda; false skips it
  ### authenticate_headers: whether shared examples set auth headers and run the unauthorized
  ###   test (defaults to authenticate:); set independently when a base-controller before_action handles auth
  ### serializer: use a particular serializer (both each_serializer and serializer)
  ### html: render the action's ERB template instead of JSON (index/show/new/edit/create/update/destroy)
  ### finder: custom record lookup (Proc/lambda or Symbol) for :show/:update/:destroy/:edit
  ### scope: custom index scope (Proc/lambda taking current_user and optional params), overrides policy_scope
  ### build: custom record builder (Proc/lambda) for :new/:create, invoked with the controller as self
  ### raise_on_invalid: use strict create!/update! semantics instead of returning 422
  ### A block given to simple_crud_for renders explicitly: it receives the records for :index,
  ### the record for :show/:new/:edit, or the record and a saved flag for :create/:update/:destroy
  def simple_crud_for(method, parameters = {}, &block)
    parameters[:block] = true if block
    parameters = parameters_with_defaults(parameters)
    klass = simple_crud_controller_model
    check_valid_method(method)
    check_policies(parameters)
    check_serializer(parameters)
    define_method(method, send("crud_lambda_for_#{method}", klass, parameters, &block))
    write_metadata(method, parameters)
  end

  def simple_crud_defaults(options = {})
    @simple_crud_defaults = simple_crud_inherited_defaults.merge(options)
  end

  def simple_crud_inherited_defaults
    ancestors.each do |ancestor|
      next unless ancestor.instance_variable_defined?(:@simple_crud_defaults)

      return ancestor.instance_variable_get(:@simple_crud_defaults)
    end
    {}
  end

  def parameters_with_defaults(parameters)
    defaults = {
      authorize: true, paginate: true, authenticate: true, authenticate_headers: nil,
      serializer: nil, html: false, finder: nil, scope: nil, build: nil, raise_on_invalid: false
    }
    defaults.merge(simple_crud_inherited_defaults).each do |key, value|
      parameters[key] = value unless parameters.key?(key)
    end
    parameters[:authenticate_headers] = parameters[:authenticate] if parameters[:authenticate_headers].nil?
    parameters
  end

  def write_metadata(method, parameters)
    @simple_crud_metadata ||= {}
    @simple_crud_metadata[method] = parameters
  end

  def simple_crud_controller_model
    to_s.split('::').last.sub('Controller', '').singularize.classify.constantize
  end

  def check_valid_method(method)
    raise ArgumentError, 'invalid method' unless %i[show index create update destroy new edit].include? method
  end

  def check_policies(parameters)
    return if !parameters.key?(:authorize) || !parameters[:authorize]

    model = simple_crud_controller_model
    return if SimpleCrud::Config.authorization_adapter.policy_defined?(model)

    raise ArgumentError, "no authorization policy configured for #{model}"
  end

  def check_serializer(parameters)
    name = parameters[:serializer].to_s
    return if name.blank? || Kernel.const_defined?(name)

    raise ArgumentError, "create a valid serializer with name #{name}"
  end
end
