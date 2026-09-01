# frozen_string_literal: true

module SimpleCrud
  class CreateContext < PersistenceContext
    private

    def run
      attrs  = permitted_params
      record = build_record
      record.assign_attributes(attrs)
      maybe_authorize(record)
      persist = ->(bang:) { bang ? record.save! : record.save }
      options = { status: :created, failure_template: :new, redirect: parameters[:redirect] || record }
      persist_and_render(record, options, persist)
    end
  end
end
