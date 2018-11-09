require_relative 'type_descriptor'

module Swaggard
  module Swagger
    class Property

      attr_reader :id, :required, :type, :description

      def initialize(yard_object)
        @id = yard_object.name.chomp('?')
        @required = !yard_object.name.end_with?('?')
        @type = TypeDescriptor.new(yard_object.types)
        @description = yard_object.text
      end

      def to_doc
        result = @type.to_doc
        result['description'] = @description if @description
        result
      end

    end
  end
end
