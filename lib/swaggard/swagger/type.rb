module Swaggard
  module Swagger
    class Type

      BASIC_TYPES = {
        'binary'    => { 'type' => 'string',  'format' => 'binary' },
        'boolean'   => { 'type' => 'boolean' },
        'byte'      => { 'type' => 'string',  'format' => 'byte' },
        'date-time' => { 'type' => 'string',  'format' => 'date-time' },
        'date'      => { 'type' => 'string',  'format' => 'date' },
        'double'    => { 'type' => 'number',  'format' => 'double' },
        'float'     => { 'type' => 'number',  'format' => 'float' },
        'hash'      => { 'type' => 'object' },
        'integer'   => { 'type' => 'integer', 'format' => 'int32' },
        'long'      => { 'type' => 'integer', 'format' => 'int64' },
        'password'  => { 'type' => 'string',  'format' => 'password' },
        'string'    => { 'type' => 'string' }
      }

      attr_reader :name

      def initialize(type)
        parse(type)
      end

      def to_doc
        type_tag_and_name
      end

      def basic_type?
        BASIC_TYPES.has_key?(@name.downcase)
      end

      def custom_data_type?
        Swaggard.configuration.custom_data_types.has_key?(@name.downcase)
      end

      private

      def parse(type)
        @name = type
      end

      def type_tag_and_name
        if basic_type?
          BASIC_TYPES[@name.downcase].clone
        elsif custom_data_type?
          Swaggard.configuration.custom_data_types[@name.downcase].clone
        else
          { '$ref' => "#/definitions/#{name}" }
        end
      end

    end
  end
end
