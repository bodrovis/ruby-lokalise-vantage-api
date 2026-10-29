# frozen_string_literal: true

module LokaliseApiNext
  module Models
    module Vantage
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
end
