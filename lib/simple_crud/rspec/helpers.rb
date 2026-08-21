# frozen_string_literal: true

module SimpleCrud
  module RSpec
    # Helpers available to the shared examples (and to apps that include
    # them). Settings resolve through the enclosing example group's
    # `simple_crud:` metadata first, falling back to the app-wide
    # SimpleCrud::RSpec::Config singleton.
    module Helpers
      def config
        SimpleCrud::RSpec::Config.instance
      end

      def simple_crud_settings
        source = ::RSpec.current_example ? ::RSpec.current_example.metadata : metadata
        source[:simple_crud] || {}
      end

      def setting(name)
        simple_crud_settings.fetch(name) { config.public_send(name) }
      end

      def get_option(method, option)
        described_class.instance_variable_get(:@simple_crud_metadata)[method][option]
      end

      # :unprocessable_entity was renamed :unprocessable_content in Rack 3.1.
      # Resolve the current Rack's canonical symbol for 422.
      def unprocessable_status
        Rack::Utils::SYMBOL_TO_STATUS_CODE.invert[422]
      end

      %i[paginate authorize authenticate serializer html finder scope build raise_on_invalid].each do |option|
        define_method("check_#{option}") { |method| get_option(method, option) }
      end

      %i[owner_association required_attribute required_error finder_key params_key invalid_status
         unauthenticated_status assert_html_template].each do |name|
        define_method(name) { resolve(setting(name)) }
      end

      def model_class
        described_class.to_s.split('::')
                       .last.sub('Controller', '').singularize.underscore
      end

      def model_class_object
        model_class.classify.constantize
      end

      def model
        @model ||= create_record(model_class, model_attributes)
      end

      def model_attributes
        resolve(setting(:model_attributes))
      end

      def create_record(klass, attributes)
        instance_exec(klass, attributes, &setting(:create_record))
      end

      def create_records(klass, count, attributes)
        instance_exec(klass, count, attributes, &setting(:create_records))
      end

      def params_for(klass)
        instance_exec(klass, &setting(:params_for))
      end

      def model_params
        @model_params ||= params_for(model_class)
      end

      def current_user
        @current_user ||= instance_exec(&setting(:current_user))
      end

      def other_user
        @other_user ||= instance_exec(&setting(:other_user))
      end

      def authenticate_request
        instance_exec(&setting(:authenticate))
      end

      def owner_foreign_key
        :"#{owner_association}_id"
      end

      # The owner association attributed to current_user, if the model has one.
      def owner_params
        owner_association ? { owner_foreign_key => current_user.id } : {}
      end

      # Extra params (e.g. a parent slug) added to every request, for nested
      # resources like /projects/:project_slug/tasks.
      def route_params
        resolve(setting(:route_params))
      end

      def with_route_params(attrs)
        route_params.merge(attrs)
      end

      # The params that identify a record for the given action, using the
      # configured finder_key when the action has a custom finder.
      def record_param(action, record, not_found: false)
        key = check_finder(action) ? finder_key : :id
        value = not_found ? "nonexistent-#{key}" : record.public_send(key)
        { key => value }
      end

      # Wraps a request body under the model's strong-params key when
      # params_key is configured (nested strong params), else passes it flat.
      def body_params(attrs)
        key = params_key
        key ? { key => attrs } : attrs
      end

      def policy_class_object
        instance_exec(model_class_object, &setting(:policy_class))
      end

      def model_serializer
        defined?(serializer) ? serializer : instance_exec(model, &setting(:serializer_class))
      end

      def make_policies_fail(method)
        allow(policy_class_object).to receive(:new)
          .and_return(instance_double(policy_class_object, "#{method}?" => false))
      end

      def make_policies_succeed(method)
        allow(policy_class_object).to receive(:new)
          .and_return(instance_double(policy_class_object, "#{method}?" => true))
      end

      def request_format(action)
        check_html(action) ? :html : :json
      end

      def resolve(value)
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

      # Runs the block with a config setting temporarily overridden, restoring
      # the original value afterwards (even if the block raises). Useful when
      # a controller's spec needs a different setting than the app-wide default.
      def with_config_override(setting, value)
        config_instance = SimpleCrud::RSpec::Config.instance
        original = config_instance.public_send(setting)
        SimpleCrud::RSpec.configure { |c| c.public_send("#{setting}=", value) }
        yield
      ensure
        SimpleCrud::RSpec.configure { |c| c.public_send("#{setting}=", original) }
      end
    end
  end
end
