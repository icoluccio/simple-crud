# frozen_string_literal: true

module SimpleCrud
  class NewContext < FormContext
    private

    def run
      record = build_record
      maybe_authorize(record)
      render_form_action(record, :new)
    end
  end
end
