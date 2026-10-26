# frozen_string_literal: true

require 'addressable/template'

module LokaliseVantage
  module Endpoints
    # Base class for building API endpoint paths.
    class Base
      class << self
        private

        def build_path(pattern, **params)
          template = Addressable::Template.new(pattern)
          values = params.transform_keys(&:to_s)

          missing = template.variables.select do |name|
            values[name].to_s.strip.empty?
          end

          raise ArgumentError, "Missing required path parameters: #{missing.join(', ')}" unless missing.empty?

          template.expand(values).to_s
        end
      end
    end
  end
end
