# frozen_string_literal: true

module Cached
  class DummyModelsController < ApplicationController
    extend SimpleCrudController
    simple_crud_defaults authorize: false, authenticate: false

    simple_crud_for :show,
                    finder: ->(p) { DummyModel.find_by!(slug: p[:slug]) },
                    cache: { key: ->(p) { "dm:#{p[:slug]}" }, ttl: 60 } do |record|
      { cached_id: record.id }
    end
  end
end
