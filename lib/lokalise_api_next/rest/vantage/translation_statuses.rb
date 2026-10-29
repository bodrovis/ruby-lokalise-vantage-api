# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides translation status API operations.
      module TranslationStatuses
        ENDPOINT = Endpoints::Vantage::TranslationStatuses
        MODEL = Models::Vantage::TranslationStatus

        def translation_status(project_id, import_id)
          uri = ENDPOINT.fetch(project_id: project_id, import_id: import_id)

          MODEL.from_response(get(uri))
        end
      end
    end
  end
end
