# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a language configured for a Vantage project.
    class ProjectLanguage < Base
      attributes %i[
        language_id
        locale
        language_name
        is_rtl
      ]
    end
  end
end
