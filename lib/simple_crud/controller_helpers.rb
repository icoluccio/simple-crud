# frozen_string_literal: true

module SimpleCrud
  # Class-level helpers shared by the CRUD lambdas defined in SimpleCrudController.
  module ControllerHelpers
    def maybe_authorize(controller, record, parameters)
      return unless parameters[:authorize]

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

    def render_show(controller, record, options, parameters, &block)
      if parameters[:html] || block
        controller.instance_variable_set(:@record, record)
        block ? controller.instance_exec(record, &block) : controller.render(:show)
      else
        controller.render({ json: record }.merge(options))
      end
    end

    def render_new(controller, record, parameters, &block)
      render_form(controller, record, :new, parameters, &block)
    end

    def render_edit(controller, record, parameters, &block)
      render_form(controller, record, :edit, parameters, &block)
    end

    def render_form(controller, record, template, parameters, &block)
      if parameters[:html] || block
        controller.instance_variable_set(:@record, record)
        block ? controller.instance_exec(record, &block) : controller.render(template)
      else
        options = {}.merge(serializer: parameters[:serializer]).compact
        controller.render({ json: record }.merge(options))
      end
    end

    def build_record(controller, klass, parameters)
      parameters[:build] ? controller.instance_exec(&parameters[:build]) : klass.new
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
      user_method = SimpleCrud::Config.user_method
      user = controller.respond_to?(user_method) ? controller.public_send(user_method) : nil
      return scope.call(user) if scope.arity == 1

      scope.call(user, controller.params)
    end

    def index_records(controller, relation, options, parameters)
      return relation unless parameters[:paginate]

      SimpleCrud::Config.pagination_adapter.paginated_records(controller, relation, options)
    end

    def find_record(klass, controller, parameters)
      record = lookup_record(klass, controller, parameters)
      raise ActiveRecord::RecordNotFound, "couldn't find #{klass}" if record.nil?
      unless record.is_a?(ActiveRecord::Base)
        raise ActiveRecord::RecordNotFound, "#{klass} finder must return a single record"
      end

      record
    end

    def lookup_record(klass, controller, parameters)
      finder = parameters[:finder]
      return klass.find(controller.params[:id]) if finder.nil?
      return klass.send(finder, controller.params) unless finder.respond_to?(:call)

      finder.call(controller.params)
    end

    def persist_and_render(controller, record, parameters, options, persist, &block)
      saved = parameters[:raise_on_invalid] ? persist.call(bang: true) : persist.call(bang: false)
      return render_persisted(controller, record, saved, options) unless block || parameters[:html]

      controller.instance_variable_set(:@record, record)
      return controller.instance_exec(record, saved, &block) if block

      if saved
        controller.redirect_to(redirect_target(controller, record, options[:redirect]))
      else
        controller.render(options[:failure_template])
      end
    end

    def save_and_render(controller, record, parameters, options, persist, &block)
      persist_and_render(controller, record, parameters,
                         options.merge(redirect: parameters[:redirect] || record), persist, &block)
    end

    def redirect_target(controller, record, target)
      target.is_a?(Proc) ? controller.instance_exec(record, &target) : target
    end

    def render_persisted(controller, record, saved, options)
      return controller.render(json: record, status: options[:status]) if saved

      controller.render json: { errors: record.errors.full_messages }, status: 422
    end
  end
end
