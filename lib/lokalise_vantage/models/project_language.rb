# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a language configured for a Vantage project.
    class ProjectLanguage < Base
      ATTRIBUTES = %i[
        language_id
        locale
        language_name
        is_rtl
      ].freeze

      attr_reader(*ATTRIBUTES)
    end
  end
end
