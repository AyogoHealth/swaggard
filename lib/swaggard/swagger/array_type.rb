require_relative 'type_descriptor'

module Swaggard
  module Swagger
    class ArrayType

      def initialize(types)
        puts types.inspect

        @types = TypeDescriptor.new(types.split(/,(?![^\<]*\>)/))
      end

      def to_doc
        if @types.types.count > 1
          { 'type' => 'array', 'items' => @types.types.map(&:to_doc) }
        else
          { 'type' => 'array', 'items' => @types.to_doc }
        end
      end

    end
  end
end
