# frozen_string_literal: true

module SimpleCrud
  # Default fetch_cached included into controllers that extend SimpleCrudController.
  # Override in the controller to use a different store.
  module CacheHelpers
    def fetch_cached(key, ttl, &block)
      Rails.cache.fetch(key, expires_in: ttl, &block)
    end

    def expire_simple_crud_cache(action, path: request.fullpath)
      Rails.cache.delete(
        SimpleCrud::ActionContext.cache_key_for(self.class.simple_crud_controller_model, action, path)
      )
    end
  end
end
