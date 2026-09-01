# frozen_string_literal: true

module SimpleCrud
  class IndexContext < ActionContext
    private

    def action_name = :index

    def run
      maybe_authorize(klass)
      cache_opts = parameters[:cache]
      cache_opts ? render_cached(cache_opts) { payload } : render_index
    end

    def payload
      opts     = serialize_opts(:each_serializer)
      relation = index_relation
      records  = index_records(relation, opts)
      controller.instance_variable_set(:@records, records)
      block ? controller.instance_exec(records, &block) : records.as_json
    end

    def render_index
      relation = index_relation
      opts     = serialize_opts(:each_serializer)
      if parameters[:html] || block
        render_records(relation, opts)
      elsif parameters[:paginate]
        SimpleCrud::Config.pagination_adapter.paginate(controller, relation, opts)
      else
        controller.render({ json: relation }.merge(opts))
      end
    end

    def render_records(relation, opts)
      records = index_records(relation, opts)
      controller.instance_variable_set(:@records, records)
      block ? controller.instance_exec(records, &block) : controller.render(:index)
    end

    def index_relation
      if parameters[:scope]
        call_scope
      elsif parameters[:authorize]
        SimpleCrud::Config.authorization_adapter.policy_scope(controller, klass)
      else
        klass.all
      end
    end

    def call_scope
      user_method = SimpleCrud::Config.user_method
      user = controller.respond_to?(user_method) ? controller.public_send(user_method) : nil
      scope = parameters[:scope]
      scope.arity == 1 ? scope.call(user) : scope.call(user, controller.params)
    end

    def index_records(relation, opts)
      return relation unless parameters[:paginate]

      SimpleCrud::Config.pagination_adapter.paginated_records(controller, relation, opts)
    end
  end
end
