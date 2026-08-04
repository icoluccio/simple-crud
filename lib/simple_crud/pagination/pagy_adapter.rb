# frozen_string_literal: true

require 'pagy'
require_relative 'adapter'

module SimpleCrud
  module Pagination
    # Assumes the controller includes Pagy::Method.
    class PagyAdapter
      include Adapter

      # 43.5.0 renamed client_max_limit -> max_limit. Ruby < 3.3 resolves to
      # the pre-rename 43.4.x, so pick whichever key the loaded Pagy expects.
      MAX_LIMIT_KEY = Gem::Version.new(Pagy::VERSION) >= Gem::Version.new('43.5.0') ? :max_limit : :client_max_limit

      def paginate(controller, klass, options)
        _pagy, records = controller.send(:pagy, klass.all, MAX_LIMIT_KEY => 100)
        controller.render({ json: records }.merge(options))
      end
    end
  end
end
