# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a segment belonging to a Vantage content unit.
    class Segment < Base
      ATTRIBUTES = %i[
        id
        number
        value
        status
        last_change_source
        content_language_id
        content_unit_id
        project_id
        metadata
        created_at
        updated_at
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
