# frozen_string_literal: true

module SimpleCrud
  class NewContext < ActionContext
    private

    def run
      record = build_record
      maybe_authorize(record)
      render_record(record, :new)
    end
  end
end
