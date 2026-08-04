# frozen_string_literal: true

module SimpleCrud
  module Pagination
    # Implement to plug in a pagination library other than wor-paginate
    # (the default, see WorPaginateAdapter).
    module Adapter
      # Called when paginate: true. Must render the response itself.
      def paginate(controller, klass, options)
        raise NotImplementedError
      end
    end
  end
end
