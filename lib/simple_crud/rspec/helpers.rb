# frozen_string_literal: true

module SimpleCrud
  module RSpec
    # Helpers available to the shared examples (and to apps that include
    # them). Everything app-specific is delegated to SimpleCrud::RSpec::Config
    # so it can be overridden without editing the examples.
    module Helpers
      def config
        SimpleCrud::RSpec::Config.instance
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
        association = resolve(config.owner_association)
        association ? { association => current_user } : {}
      end

      def create_record(klass, attributes)
        instance_exec(klass, attributes, &config.create_record)
      end

      def create_records(klass, count, attributes)
        instance_exec(klass, count, attributes, &config.create_records)
      end

      def params_for(klass)
        instance_exec(klass, &config.params_for)
      end

      def model_params
        @model_params ||= params_for(model_class)
      end

      def current_user
        @current_user ||= instance_exec(&config.current_user)
      end

      def authenticate_request
        instance_exec(&config.authenticate)
      end

      def owner_association
        resolve(config.owner_association)
      end

      def owner_foreign_key
        :"#{owner_association}_id"
      end

      def required_attribute
        resolve(config.required_attribute)
      end

      def required_error
        resolve(config.required_error)
      end

      def finder_key
        resolve(config.finder_key)
      end

      def params_key
        resolve(config.params_key)
      end

      # Wraps a request body under the model's strong-params key when
      # params_key is configured (nested strong params), else passes it flat.
      def body_params(attrs)
        key = params_key
        key ? { key => attrs } : attrs
      end

      def unauthenticated_status
        resolve(config.unauthenticated_status)
      end

      def assert_html_template
        resolve(config.assert_html_template)
      end

      def policy_class_object
        instance_exec(model_class_object, &config.policy_class)
      end

      def model_serializer
        defined?(serializer) ? serializer : instance_exec(model, &config.serializer_class)
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
