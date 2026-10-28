# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Base class for mapping API responses to model attributes.
    class Base
      attr_reader :warnings

      class << self
        def from_response(response)
          new(
            response.fetch('data'),
            warnings: response.fetch('warnings', [])
          )
        end

        def attributes(fields)
          const_set(:ATTRIBUTES, fields.freeze)
          attr_reader(*fields)
        end
      end

      def initialize(json, warnings: [])
        @warnings = warnings

        self.class::ATTRIBUTES.each do |name|
          json_key = name.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }

          instance_variable_set(:"@#{name}", json[json_key])
        end
      end
    end
  end
end
