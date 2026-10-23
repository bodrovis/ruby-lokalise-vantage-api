# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a content unit in a Vantage project.
    class ContentUnit < Base
      ATTRIBUTES = %i[
        id
        project_id
        type
        key
        position
        source_segments_count
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
