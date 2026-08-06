# frozen_string_literal: true

def get_option(method, option)
  described_class.instance_variable_get(:@simple_crud_metadata)[method][option]
end

%i[paginate authorize authenticate serializer html finder scope raise_on_invalid].each do |option|
  define_method("check_#{option}") do |method|
    get_option(method, option)
  end
end

def model_class
  described_class.to_s.split('::')
                 .last.sub('Controller', '').singularize.underscore
end

def model_serializer
  defined?(serializer) ? serializer : "#{model.class}_serializer".classify.constantize
end

def model
  @model ||= create(model_class, **model_attributes)
end

def model_attributes
  respond_to?(:current_user) ? { user: current_user } : {}
end

def model_class_object
  model_class.classify.constantize
end

def policy_class_object
  "#{model_class_object}Policy".classify.constantize
end

def make_policies_fail(method)
  allow(policy_class_object).to receive(:new)
    .and_return(instance_double(policy_class_object, "#{method}?" => false))
end

def make_policies_succeed(method)
  allow(policy_class_object).to receive(:new)
    .and_return(instance_double(policy_class_object, "#{method}?" => true))
end

def model_params
  @model_params ||= attributes_for(model_class)
end
