# frozen_string_literal: true

module LokaliseVantage
  # Combines API operations and HTTP functionality.
  module Rest
    include Connection
    include Request

    include ContentUnits
    include Exports
    include Imports
    include Projects
    include ProjectItems
    include ProjectLanguages
    include Segments
    include Tasks
    include TranslationStatuses
    include Uploads
  end
end
