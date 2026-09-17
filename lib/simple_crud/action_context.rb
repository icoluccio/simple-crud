# frozen_string_literal: true

module SimpleCrud
  class ActionContext
    DEFAULT_CACHE_TTL = 300

    attr_reader :controller, :klass, :parameters, :block

    def self.cache_key_for(model, action, path)
      "#{model.model_name.singular}:#{action}:v1:#{path}"
    end

    def initialize(controller, klass, parameters, &block)
      @controller = controller
      @klass      = klass
      @parameters = parameters
      @block      = block
    end

    def call
      controller.authenticate_user! if parameters[:authenticate]
      run
    end

    private

    def run
      raise NotImplementedError, "#{self.class} must implement run"
    end

    def action_name
      raise NotImplementedError, "#{self.class} must implement action_name to support caching"
    end

    def maybe_authorize(object)
      return unless parameters[:authorize]

      SimpleCrud::Config.authorization_adapter.authorize(controller, object)
    end

    def find_record
      record = lookup_record
      raise ActiveRecord::RecordNotFound, "couldn't find #{klass}" if record.nil?
      unless record.is_a?(ActiveRecord::Base)
        raise ActiveRecord::RecordNotFound, "#{klass} finder must return a single record"
      end

      record
    end

    def lookup_record
      finder = parameters[:finder]
      return find_by_id if finder.nil?
      return klass.send(finder, controller.params) unless finder.respond_to?(:call)

      controller.instance_exec(controller.params, &finder)
    end

    def find_by_id
      klass.find(controller.params[:id])
    end

    def build_record
      parameters[:build] ? controller.instance_exec(&parameters[:build]) : klass.new
    end

    def permitted_params
      controller.send("#{klass.model_name.singular}_params")
    end

    def serialize_opts(key)
      opts = { key => parameters[:serializer] }.compact
      options = serializer_options
      opts[:serializer_options] = options if options.present?
      opts
    end

    def serializer_options(record = nil)
      callable = parameters[:serializer_options]
      return {} unless callable

      callable.arity.zero? ? controller.instance_exec(&callable) : controller.instance_exec(record, &callable)
    end

    def render_record(record, template)
      return render_html_record(record, template) if parameters[:html] || block

      render_json_record(record)
    end

    def render_html_record(record, template)
      controller.instance_variable_set(:@record, record)
      block ? controller.instance_exec(record, &block) : controller.render(template)
    end

    def render_json_record(record)
      serializer = parameters[:serializer]
      controller.render json: SimpleCrud::Serializer.render(serializer, record, serializer_options(record))
    end

    def render_cached(cache_opts, &fetch_block)
      key    = resolve_cache_key(cache_opts)
      ttl    = cache_opts[:ttl] || DEFAULT_CACHE_TTL
      result = controller.send(:fetch_cached, key, ttl, &fetch_block)
      controller.render json: result
    end

    def resolve_cache_key(cache_opts)
      k = cache_opts[:key]
      return default_cache_key if k.nil?

      k.respond_to?(:call) ? controller.instance_exec(controller.params, &k) : k
    end

    def default_cache_key
      self.class.cache_key_for(klass, action_name, controller.request.fullpath)
    end
  end
end
