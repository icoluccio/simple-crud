# frozen_string_literal: true

module SimpleCrud
  class PersistenceContext < ActionContext
    private

    def persist_and_render(record, options, persist)
      saved = parameters[:raise_on_invalid] ? persist.call(bang: true) : persist.call(bang: false)
      return render_persisted(record, saved, options) unless block || parameters[:html]

      controller.instance_variable_set(:@record, record)
      block ? controller.instance_exec(record, saved, &block) : render_html_redirect(record, saved, options)
    end

    def render_html_redirect(record, saved, options)
      if saved
        controller.redirect_to(redirect_target(record, options[:redirect]))
      else
        controller.render(options[:failure_template])
      end
    end

    def redirect_target(record, target)
      target.is_a?(Proc) ? controller.instance_exec(record, &target) : target
    end

    def render_persisted(record, saved, options)
      return controller.render(json: record, status: options[:status]) if saved

      controller.render json: { errors: record.errors.full_messages }, status: 422
    end
  end
end
