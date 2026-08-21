# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Settings resolution: `simple_crud:` example-group metadata first,
      # falling back to the app-wide SimpleCrud::RSpec::Config singleton.
      module Settings
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

        def resolve(value)
          value.is_a?(Proc) ? instance_exec(&value) : value
        end

        %i[owner_association required_attribute required_error finder_key params_key invalid_status
           unauthenticated_status assert_html_template].each do |name|
          define_method(name) { resolve(setting(name)) }
        end

        def created_record_check
          setting(:created_record_check)
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
end
