# frozen_string_literal: true

module SimpleCrud
  # Default fetch_cached included into controllers that extend SimpleCrudController.
  # Override in the controller to use a different store.
  module CacheHelpers
    def fetch_cached(key, ttl, &block)
      Rails.cache.fetch(key, expires_in: ttl, &block)
    end
  end
end
