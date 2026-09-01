# frozen_string_literal: true

module SimpleCrud
  class ShowContext < ActionContext
    private

    def action_name = :show

    def run
      cache_opts = parameters[:cache]
      if cache_opts
        render_cached(cache_opts) { execute }
      else
        record = find_record
        maybe_authorize(record)
        render_show(record)
      end
    end

    def execute
      record = find_record
      maybe_authorize(record)
      controller.instance_variable_set(:@record, record)
      block ? controller.instance_exec(record, &block) : record.as_json
    end

    def render_show(record)
      if parameters[:html] || block
        controller.instance_variable_set(:@record, record)
        block ? controller.instance_exec(record, &block) : controller.render(:show)
      else
        controller.render({ json: record }.merge(serialize_opts(:serializer)))
      end
    end
  end
end
