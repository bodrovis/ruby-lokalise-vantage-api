# frozen_string_literal: true

module LokaliseApiNext
  module Models
    # Represents the translation status of a Vantage import.
    class TranslationStatus < Base
      attributes %i[
        project_id
        import_id
        status
        languages
      ]
    end
  end
end
