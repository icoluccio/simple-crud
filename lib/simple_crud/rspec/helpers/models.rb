# frozen_string_literal: true

module SimpleCrud
  module RSpec
    module Helpers
      # Building the record under test and the params used to persist it.
      module Models
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

        def model_serializer
          defined?(serializer) ? serializer : instance_exec(model, &setting(:serializer_class))
        end

        def rendered_record
          controller.instance_variable_get(:@record)
        end

        def rendered_records
          controller.instance_variable_get(:@records)
        end
      end
    end
  end
end
