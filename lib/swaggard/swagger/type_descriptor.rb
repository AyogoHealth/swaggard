require_relative 'type'

module Swaggard
  module Swagger
    class TypeDescriptor

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
          Type.new(type)
        end
      end

    end
  end
end
