# frozen_string_literal: true

module LokaliseApiNext
  module Models
    module Vantage
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
end
