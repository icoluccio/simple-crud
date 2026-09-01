# frozen_string_literal: true

module SimpleCrud
  # Builds the lambda installed as each action declared with simple_crud_for.
  module ActionLambdas
    %i[show new edit index create update destroy].each do |action|
      ctx_class = SimpleCrud.const_get(:"#{action.to_s.capitalize}Context")
      define_method(:"crud_lambda_for_#{action}") do |klass, parameters = {}, &block|
        -> { ctx_class.new(self, klass, parameters, &block).call }
      end
    end
  end
end
