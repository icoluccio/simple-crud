# frozen_string_literal: true

module SimpleCrud
  # Resolves the owner shared by owned_by: and parent:.
  class RelationSource
    def initialize(controller, klass, parameters)
      @controller = controller
      @klass      = klass
      @parameters = parameters
    end

    def configured?
      !owned_by.nil? || !parent.nil?
    end

    # nil when the owner can't be resolved.
    def relation
      return owner.relation if owned_by
      return parent_source.relation if parent

      nil
    end

    def relation!
      relation || raise(ActiveRecord::RecordNotFound, "no #{description} to scope the record to")
    end

    def user
      Source.user(controller)
    end

    private

    attr_reader :controller, :klass, :parameters

    def owned_by = parameters[:owned_by]

    def parent = parameters[:parent]

    def description
      owned_by ? "owner for #{owned_by}" : "parent for #{parent}"
    end

    def owner
      OwnerSource.new(controller, parameters[:owned_by])
    end

    def parent_source
      ParentSource.new(controller, klass, parameters)
    end

    # Shared by both relation sources.
    module Source
      def self.user(controller)
        user_method = SimpleCrud::Config.user_method
        controller.respond_to?(user_method, true) ? controller.send(user_method) : nil
      end
    end

    # nil without a user.
    class OwnerSource
      def initialize(controller, association)
        @controller  = controller
        @association = association
      end

      def relation
        Source.user(@controller)&.public_send(@association)
      end
    end

    # A Symbol resolves method then @ivar.
    class ParentSource
      def initialize(controller, klass, parameters)
        @controller = controller
        @klass      = klass
        @parameters = parameters
      end

      def relation
        resolved&.public_send(association)
      end

      private

      def resolved
        reference = @parameters[:parent]
        return @controller.instance_exec(&reference) if reference.respond_to?(:call)

        by_method_or_ivar(reference)
      end

      def by_method_or_ivar(reference)
        return @controller.send(reference) if @controller.respond_to?(reference, true)

        ivar = :"@#{reference}"
        return @controller.instance_variable_get(ivar) if @controller.instance_variable_defined?(ivar)

        raise ArgumentError, "parent: #{reference} is neither a controller method nor an @#{reference} ivar"
      end

      def association
        @parameters[:parent_association] || @klass.model_name.plural.to_sym
      end
    end
  end
end
