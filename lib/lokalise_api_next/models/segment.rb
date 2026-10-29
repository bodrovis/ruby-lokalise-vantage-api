# frozen_string_literal: true

module LokaliseApiNext
  module Models
    # Represents a segment belonging to a Vantage content unit.
    class Segment < Base
      attributes %i[
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
      ]
    end
  end
end
