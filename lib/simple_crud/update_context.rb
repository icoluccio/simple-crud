# frozen_string_literal: true

module SimpleCrud
  class UpdateContext < PersistenceContext
    private

    def run
      record = find_record
      maybe_authorize(record)
      attrs   = permitted_params
      persist = ->(bang:) { bang ? record.update!(attrs) : record.update(attrs) }
      options = { status: :ok, failure_template: :edit, redirect: parameters[:redirect] || record }
      persist_and_render(record, options, persist)
    end
  end
end
