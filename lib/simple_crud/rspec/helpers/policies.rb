# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Locating the policy object for the model under test and stubbing it
      # to allow or deny.
      module Policies
        def policy_class_object
          instance_exec(model_class_object, &setting(:policy_class))
        end

        def make_policies_fail(method)
          allow(policy_class_object).to receive(:new)
            .and_return(instance_double(policy_class_object, "#{method}?" => false))
        end

        def make_policies_succeed(method)
          allow(policy_class_object).to receive(:new)
            .and_return(instance_double(policy_class_object, "#{method}?" => true))
        end
      end
    end
  end
end
