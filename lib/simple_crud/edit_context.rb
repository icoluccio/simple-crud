# frozen_string_literal: true

module SimpleCrud
  class EditContext < ActionContext
    private

    def run
      record = find_record
      maybe_authorize(record)
      render_record(record, :edit)
    end
  end
end
