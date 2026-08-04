# frozen_string_literal: true

module SimpleCrud
  module Pagination
    # Implement this and pass an instance to SimpleCrud.configure to plug in
    # a library other than wor-paginate (the default, see WorPaginateAdapter).
    module Adapter
      # Called when paginate: true. Must render the response itself, same
      # as the other generated CRUD actions -- there's no render step after.
      def paginate(controller, klass, options)
        raise NotImplementedError
      end
    end
  end
end
