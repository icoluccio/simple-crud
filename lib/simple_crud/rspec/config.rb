# frozen_string_literal: true

module SimpleCrud
  # Test helpers: SimpleCrud::RSpec.configure exposes the shared examples'
  # configuration for apps on a different stack than the gem's.
  module RSpec
    def self.configure
      yield Config.instance
    end

    # Configures how the shared examples create records, authenticate
    # requests and introspect policies/serializers. The defaults match the
    # gem's own stack (Devise-JWT + FactoryBot + Pundit + ActiveModel
    # Serializers), so apps on a different stack can override them via
    # SimpleCrud::RSpec.configure instead of editing the examples.
    #
    # Callable settings (authenticate, current_user, create_record,
    # create_records, attributes_for, policy_class, serializer_class) run in
    # the example-group context, so they can call helpers such as `create`,
    # `request` and `current_user`.
    class Config
      DEFAULTS = {
        authenticate: lambda {
          headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
          request.headers.merge!(Devise::JWT::TestHelpers.auth_headers(headers, current_user))
        },
        current_user: -> { create(:user) },
        other_user: -> { create(:user) },
        create_record: ->(klass, attributes) { create(klass, **attributes) },
        create_records: ->(klass, count, attributes) { create_list(klass, count, **attributes) },
        params_for: ->(klass) { attributes_for(klass) },
        owner_association: :user,
        required_attribute: :name,
        required_error: "Name can't be blank",
        finder_key: :slug,
        params_key: nil,
        invalid_status: :ok,
        unauthenticated_status: :unauthorized,
        assert_html_template: true,
        policy_class: ->(klass) { "#{klass}Policy".constantize },
        serializer_class: ->(model) { "#{model.class}_serializer".classify.constantize }
      }.freeze

      class << self
        def instance
          @instance ||= new
        end
      end

      def initialize
        @values = {}
      end

      DEFAULTS.each_key do |key|
        define_method(key) { @values.fetch(key, DEFAULTS[key]) }
        define_method("#{key}=") { |value| @values[key] = value }
      end
    end
  end
end
