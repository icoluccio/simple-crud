# frozen_string_literal: true

module SimpleCrud
  module Pagination
    # Implement to plug in a pagination library other than wor-paginate
    # (the default, see WorPaginateAdapter).
    module Adapter
      # Called when paginate: true. Must render the response itself.
      def paginate(controller, relation, options)
        raise NotImplementedError
      end

      # Called when rendering :index as HTML (html: true or a block given) and
      # paginate: true. Must return the current page's records without rendering.
      def paginated_records(controller, relation, options)
        raise NotImplementedError
      end
    end
  end
end
