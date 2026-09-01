# frozen_string_literal: true

module SimpleCrud
  class DestroyContext < PersistenceContext
    private

    def run
      record = find_record
      maybe_authorize(record)
      persist = ->(bang:) { bang ? record.destroy! : record.destroy }
      options = { status: :ok, failure_template: :show, redirect: parameters[:redirect] || klass }
      persist_and_render(record, options, persist)
    end
  end
end
