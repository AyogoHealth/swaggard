require_relative 'type'
require_relative 'array_type'

module Swaggard
  module Swagger
    class TypeDescriptor
      attr_reader :types

      def initialize(types)
        parse(types)
      end

      def to_doc
        if @types.length > 1
          { 'oneOf' => @types.map(&:to_doc) }
        else
          @types.first.to_doc
        end
      end


      private

      def parse(types)
        @types = types.map do |type|
          parts = type.split(/[<>]/)

          if parts.first =~ /array/i
            parts.slice!(0)
            nested = parts.join('<') + ('>' * (parts.length - 1))

            ArrayType.new(nested)
          else
            Type.new(type)
          end
        end
      end

    end
  end
end
