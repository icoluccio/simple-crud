# frozen_string_literal: true

module SimpleCrud
  class EditContext < FormContext
    private

    def run
      record = find_record
      maybe_authorize(record)
      render_form_action(record, :edit)
    end
  end
end
