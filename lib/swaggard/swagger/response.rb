require_relative 'type_descriptor'

module Swaggard
  module Swagger
    class Response

      DEFAULT_STATUS_CODE = 'default'
      DEFAULT_DESCRIPTION = 'successful operation'
      PRIMITIVE_TYPES = %w[integer long float double string byte binary boolean date date-time password hash]

      attr_writer :status_code, :description

      def initialize(operation_name)
        @operation_name = operation_name
        @response_model = ResponseModel.new
      end

      def definition
        return unless @response_root.present?

        wrapper = Swaggard.configuration.response_wrapper
        @definition ||= wrapper.new("#{@operation_name}_response").tap do |definition|
          definition.add_property(@response_model)
        end
      end

      def status_code
        @status_code || DEFAULT_STATUS_CODE
      end

      def response_class=(value)
        @response_model.parse(value)
      end

      def response_root=(root)
        @response_root = root
        @response_model.id = root
      end

      def description
        @description || DEFAULT_DESCRIPTION
      end

      def to_doc
        { 'description' => description }.tap do |doc|
          schema = if @response_root.present?
                     { '$ref' => "#/definitions/#{definition.id}" }
                   elsif @response_model.types.present?
                     @response_model.to_doc
                   end

          doc.merge!('schema' => schema) if schema
        end
      end

      private

      class ResponseModel
        attr_accessor :id, :required, :types

        def parse(value)
          @required = !value.end_with?('?')
          @types = TypeDescriptor.new(value.chomp('?').split(/,(?![^\<]*\>)/))
        end

        def to_doc
          @types.to_doc
        end
      end
    end
  end
end
