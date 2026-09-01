# frozen_string_literal: true

module SimpleCrud
  class FormContext < ActionContext
    private

    def render_form_action(record, template)
      if parameters[:html] || block
        controller.instance_variable_set(:@record, record)
        block ? controller.instance_exec(record, &block) : controller.render(template)
      else
        controller.render({ json: record }.merge(serialize_opts(:serializer)))
      end
    end
  end
end
