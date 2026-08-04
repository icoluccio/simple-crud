# frozen_string_literal: true

module SimpleCrud
  module Pagination
    # Translates simple_crud's pagination calls into a specific pagination
    # library's API. Implement this and pass an instance to SimpleCrud.configure
    # to plug in a library other than wor-paginate (the default, see
    # WorPaginateAdapter).
    module Adapter
      # Called from inside the generated index action when paginate: true.
      # Must render the response itself (via +controller.render+), the same
      # way the other generated CRUD actions do -- there's no separate
      # render step after this returns.
      #
      # +options+ already carries :each_serializer (compacted, so it's
      # simply absent when no custom serializer was configured).
      def paginate(controller, klass, options)
        raise NotImplementedError
      end
    end
  end
end
