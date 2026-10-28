# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a content unit in a Vantage project.
    class ContentUnit < Base
      attributes %i[
        id
        project_id
        type
        key
        position
        source_segments_count
      ]
    end
  end
end
