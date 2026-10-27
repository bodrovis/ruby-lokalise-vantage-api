# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents an item belonging to a Vantage project.
    class ProjectItem < Base
      ATTRIBUTES = %i[
        id
        project_id
        name
        created_at
        updated_at
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
