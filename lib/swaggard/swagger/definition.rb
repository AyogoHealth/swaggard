module Swaggard
  module Swagger
    class Definition

      attr_reader :id

      def initialize(id)
        @id = id
        @properties = []
      end

      def add_property(property)
        @properties << property
      end

      def to_doc
        doc = {
          'type'        => 'object',
          'properties'  => Hash[@properties.map { |property| [property.id, property.to_doc] }]
        }

        required = @properties.select { |prop| prop.respond_to?(:required) && prop.required }.map { |property| property.id }

        unless required.empty?
          doc['required'] = required
        end

        doc
      end

    end
  end
end
