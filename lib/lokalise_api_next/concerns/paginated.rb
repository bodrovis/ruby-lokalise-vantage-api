# frozen_string_literal: true

module LokaliseApiNext
  module Concerns
    # Adds pagination metadata to API collections.
    module Paginated
      attr_reader :page_count, :cursor

      def initialize(json_items, meta = nil)
        super

        raise ArgumentError, 'Pagination metadata is missing' unless meta.is_a?(Hash)

        @page_count = meta.fetch('count')
        @cursor = meta['cursor']
        @has_more = meta.fetch('hasMore')
      end

      def more?
        @has_more
      end
    end
  end
end
