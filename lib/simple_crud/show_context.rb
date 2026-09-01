# frozen_string_literal: true

module SimpleCrud
  class ShowContext < ActionContext
    private

    def action_name = :show

    def run
      cache_opts = parameters[:cache]
      if cache_opts
        render_cached(cache_opts) { payload }
      else
        record = find_record
        maybe_authorize(record)
        render_record(record, :show)
      end
    end

    def payload
      record = find_record
      maybe_authorize(record)
      controller.instance_variable_set(:@record, record)
      block ? controller.instance_exec(record, &block) : record.as_json
    end
  end
end
