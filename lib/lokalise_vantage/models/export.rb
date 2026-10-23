# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a Vantage export operation and its status.
    class Export < Base
      ATTRIBUTES = %i[
        export_id
        status
        created_at
        total_items_count
        processed_items_count
        fail_reason
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
