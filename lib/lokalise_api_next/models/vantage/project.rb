# frozen_string_literal: true

module LokaliseApiNext
  module Models
    module Vantage
      # Represents a Vantage project.
      class Project < Base
        attributes %i[
          project_id
          team_id
          name
          description
          base_language
          target_languages
          translation_settings
          content_source_type
          content_source_name
          project_type
        ]
      end
    end
  end
end
