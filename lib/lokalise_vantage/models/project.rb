# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a Vantage project.
    class Project < Base
      ATTRIBUTES = %i[
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
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
