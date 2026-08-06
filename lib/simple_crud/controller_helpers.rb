# frozen_string_literal: true

module SimpleCrud
  # Class-level helpers shared by the CRUD lambdas defined in SimpleCrudController.
  module ControllerHelpers
    def maybe_authorize(controller, record, parameters)
      return unless parameters[:authorize] && parameters[:authenticate]

      SimpleCrud::Config.authorization_adapter.authorize(controller, record)
    end

    def render_index(controller, klass, options, parameters, &block)
      relation = index_relation(controller, klass, parameters)

      if parameters[:html] || block
        records = index_records(controller, relation, options, parameters)
        controller.instance_variable_set(:@records, records)
        block ? controller.instance_exec(records, &block) : controller.render(:index)
      elsif parameters[:paginate]
        SimpleCrud::Config.pagination_adapter.paginate(controller, relation, options)
      else
        controller.render({ json: relation }.merge(options))
      end
    end

    def index_relation(controller, klass, parameters)
      if parameters[:scope]
        call_scope(parameters[:scope], controller)
      elsif parameters[:authorize]
        SimpleCrud::Config.authorization_adapter.policy_scope(controller, klass)
      else
        klass.all
      end
    end

    def call_scope(scope, controller)
      user = controller.current_user
      return scope.call(user) if scope.arity == 1

      scope.call(user, controller.params)
    end

    def index_records(controller, relation, options, parameters)
      return relation unless parameters[:paginate]

      SimpleCrud::Config.pagination_adapter.paginated_records(controller, relation, options)
    end

    def find_record(klass, controller, parameters)
      finder = parameters[:finder]
      record = if finder.nil?
                 klass.find(controller.params[:id])
               elsif finder.respond_to?(:call)
                 finder.call(controller.params)
               else
                 klass.send(finder, controller.params)
               end
      raise ActiveRecord::RecordNotFound, "couldn't find #{klass}" if record.nil?

      record
    end

    def render_save_outcome(controller, record, parameters, status, &persist)
      if parameters[:raise_on_invalid]
        persist.call(bang: true)
        controller.render json: record, status: status
      elsif persist.call(bang: false)
        controller.render json: record, status: status
      else
        controller.render json: { errors: record.errors.full_messages }, status: 422
      end
    end
  end
end
