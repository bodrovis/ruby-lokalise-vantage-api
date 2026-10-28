# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents an item belonging to a Vantage project.
    class ProjectItem < Base
      attributes %i[
        id
        project_id
        name
        created_at
        updated_at
      ]
    end
  end
end
