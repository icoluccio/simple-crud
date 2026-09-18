# frozen_string_literal: true

require 'active_support/all'
require_relative 'config'
require_relative 'serializer'
require_relative 'cache_helpers'
require_relative 'relation_source'
require_relative 'action_context'
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
  ### scope: custom index scope for :index, overriding policy_scope. A Proc/lambda run with the
  ###   controller as self (arity 0 no args, arity 1 the user, else user and params), or a Symbol
  ###   naming a model class method taking (current_user, params)
  ### build: custom record builder (Proc/lambda) for :new/:create, invoked with the controller as self
  ### owned_by: association on Config.user_method for the default finder/build/index-scope
  ### parent: nested-route parent for the same defaults; exclusive with owned_by:
  ### parent_association: parent association when it differs from the controller model's plural
  ### notice:/alert: flash on the html: create/update/destroy success redirect / failure re-render
  ### raise_on_invalid: use strict create!/update! semantics instead of returning 422
  ### A block given to simple_crud_for renders explicitly: it receives the records for :index,
  ### the record for :show/:new/:edit, or the record and a saved flag for :create/:update/:destroy
  ### An Array of actions declares several at once with the same options
  def simple_crud_for(method, parameters = {}, &block)
    return method.each { |name| simple_crud_for(name, parameters.dup, &block) } if method.is_a?(Array)

    parameters[:block] = true if block
    parameters = parameters_with_defaults(parameters)
    klass = simple_crud_controller_model
    check_valid_method(method)
    check_relation_source(parameters)
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
    defaults.merge(simple_crud_inherited_defaults).each do |key, value|
      parameters[key] = value unless parameters.key?(key)
    end
    parameters[:authenticate_headers] ||= parameters[:authenticate]
    parameters
  end

  def defaults
    {
      authorize: true, paginate: true, authenticate: true, authenticate_headers: nil,
      serializer: nil, serializer_options: nil, status: nil, after_persist: nil, html: false,
      finder: nil, scope: nil, build: nil, owned_by: nil, parent: nil, parent_association: nil,
      notice: nil, alert: nil, raise_on_invalid: false
    }
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

  def check_relation_source(parameters)
    return unless parameters[:owned_by] && parameters[:parent]

    raise ArgumentError, 'owned_by: and parent: are mutually exclusive, they both scope the same action'
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
