# frozen_string_literal: true

module SimpleCrud
  class PersistenceContext < ActionContext
    private

    def persist_and_render(record, options, persist)
      saved = parameters[:raise_on_invalid] ? persist.call(bang: true) : persist.call(bang: false)
      run_after_persist(record, saved)
      return render_persisted(record, saved, options) unless block || parameters[:html]

      controller.instance_variable_set(:@record, record)
      block ? controller.instance_exec(record, saved, &block) : render_html_redirect(record, saved, options)
    end

    def run_after_persist(record, saved)
      hook = parameters[:after_persist]
      controller.instance_exec(record, saved, &hook) if hook
    end

    def render_html_redirect(record, saved, options)
      return render_html_failure(options) unless saved

      set_flash(:notice, parameters[:notice])
      controller.redirect_to(redirect_target(record, options[:redirect]))
    end

    def render_html_failure(options)
      set_flash(:alert, parameters[:alert], now: true)
      controller.render(options[:failure_template])
    end

    def set_flash(key, message, now: false)
      return if message.nil? || !controller.respond_to?(:flash)

      target = now ? controller.flash.now : controller.flash
      target[key] = message
    end

    def redirect_target(record, target)
      target.is_a?(Proc) ? controller.instance_exec(record, &target) : target
    end

    def render_persisted(record, saved, options)
      return render_success(record, options[:status]) if saved

      controller.render json: { errors: record.errors.full_messages }, status: 422
    end

    def render_success(record, status)
      return controller.head(status) if status == :no_content

      controller.render json: payload(record), status: status
    end

    def payload(record)
      SimpleCrud::Serializer.render(parameters[:serializer], record, serializer_options(record))
    end
  end
end
