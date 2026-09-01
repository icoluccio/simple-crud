# frozen_string_literal: true

module SimpleCrud
  # Builds the lambda installed as each action declared with simple_crud_for.
  module ActionLambdas
    CONTEXTS = {
      show: ShowContext,
      new: NewContext,
      edit: EditContext,
      index: IndexContext,
      create: CreateContext,
      update: UpdateContext,
      destroy: DestroyContext
    }.freeze

    CONTEXTS.each do |action, ctx_class|
      define_method(:"crud_lambda_for_#{action}") do |klass, parameters = {}, &block|
        -> { ctx_class.new(self, klass, parameters, &block).call }
      end
    end
  end
end
