# frozen_string_literal: true

module SimpleCrud
  # Builds the lambda installed as each action declared with simple_crud_for.
  module ActionLambdas
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

    # The find-instead-of-build twin of :new.
    def crud_lambda_for_edit(klass, parameters = {}, &block)
      lambda do
        authenticate_user! if parameters[:authenticate]
        requested = SimpleCrudController.find_record(klass, self, parameters)
        SimpleCrudController.maybe_authorize(self, requested, parameters)
        SimpleCrudController.render_edit(self, requested, parameters, &block)
      end
    end

    def crud_lambda_for_index(klass, parameters = {}, &block)
      lambda do
        authenticate_user! if parameters[:authenticate]
        SimpleCrudController.maybe_authorize(self, klass, parameters)
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
        options = { status: :ok, failure_template: :show, redirect: parameters[:redirect] || klass }
        persist = ->(bang:) { bang ? requested.destroy! : requested.destroy }
        SimpleCrudController.persist_and_render(self, requested, parameters, options, persist, &block)
      end
    end
  end
end
