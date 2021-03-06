require 'json'
require 'yard'

require 'swaggard/api_definition'
require 'swaggard/configuration'
require 'swaggard/engine'
require 'swaggard/response_wrapper'

require 'swaggard/parsers/controllers'
require 'swaggard/parsers/models'
require 'swaggard/parsers/routes'

module Swaggard

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Swaggard::Configuration.new
    end

    # Register some custom yard tags
    def register_custom_yard_tags!
      ::YARD::Tags::Library.define_tag('Controller\'s tag',  :tag)
      ::YARD::Tags::Library.define_tag('Query parameter', :query_parameter)
      ::YARD::Tags::Library.define_tag('Form parameter',  :form_parameter)
      ::YARD::Tags::Library.define_tag('Body parameter',  :body_parameter)
      ::YARD::Tags::Library.define_tag('Parameter list',  :parameter_list)
      ::YARD::Tags::Library.define_tag('Response class',  :response_class)
      ::YARD::Tags::Library.define_tag('Response Root',  :response_root)
      ::YARD::Tags::Library.define_tag('Response Status',  :response_status)
    end

    def register_definition(dfn)
      if instance_variable_defined?(:@api)
        @api.definitions << dfn
      else
        @global_definitions ||= []
        @global_definitions << dfn
      end
    end

    def get_doc(host)
      load!

      doc = @api.to_doc

      doc['host'] = host if doc['host'].blank?

      doc
    end

    private

    def load!
      @api = Swaggard::ApiDefinition.new

      parse_models
      parse_controllers

      if instance_variable_defined?(:@global_definitions)
        @api.definitions.concat(@global_definitions)
      end
    end

    def parse_controllers
      parser = Parsers::Controllers.new

      configuration.controllers_paths.each do |path|
        Dir[path].each do |file|
          yard_objects = get_yard_objects(file)

          tag, operations = parser.run(yard_objects, routes)

          next unless tag

          @api.add_tag(tag)
          operations.each { |operation| @api.add_operation(operation) }
        end
      end
    end

    def routes
      return @routes if @routes

      parser = Parsers::Routes.new
      @routes = parser.run(configuration.routes)
    end

    def parse_models
      parser = Parsers::Models.new

      definitions =[]
      configuration.models_paths.each do |path|
        Dir[path].each do |file|
          yard_objects = get_yard_objects(file)

          definitions.concat(parser.run(yard_objects))
        end

        @api.definitions = definitions
      end
    end

    def get_yard_objects(file)
      ::YARD.parse(file)
      yard_objects = ::YARD::Registry.all
      ::YARD::Registry.clear

      yard_objects
    end

  end
end
