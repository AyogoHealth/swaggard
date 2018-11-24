require_relative '../swagger/operation'
require_relative '../swagger/tag'

module Swaggard
  module Parsers
    class Controllers

      def run(yard_objects, routes)
        tag = nil
        operations = []

        yard_objects.each do |yard_object|
          if yard_object.type == :class
            tag = Swagger::Tag.new(yard_object)
          elsif tag && yard_object.type == :method
            operation = Swagger::Operation.new(yard_object, tag, routes)
            next unless operation.valid?

            if operation.http_method.include?('|')
              methods = operation.http_method.split('|')
              methods.each do |verb|
                op = operation.clone
                op.http_method = verb

                operations << op
              end
            else
              operations << operation
            end
          end
        end

        return unless operations.any?

        return tag, operations
      end

    end
  end
end
