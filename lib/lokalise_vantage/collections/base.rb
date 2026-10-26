# frozen_string_literal: true

require 'forwardable'

module LokaliseVantage
  module Collections
    # Base class for API resource collections.
    class Base
      include Enumerable
      extend Forwardable

      attr_reader :items

      def_delegators :items, :[], :last, :each, :size, :empty?

      def self.from_response(response)
        new(response.fetch('data'), response.fetch('meta', nil))
      end

      def initialize(json_items, _meta = nil)
        model_klass = self.class::MODEL
        @items = json_items.map { |json_item| model_klass.new(json_item) }
      end
    end
  end
end
