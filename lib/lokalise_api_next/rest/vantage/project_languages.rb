# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project languages API operations.
      module ProjectLanguages
        ENDPOINT = Endpoints::Vantage::ProjectLanguages
        COLLECTION = Collections::Vantage::ProjectLanguages

        def project_languages(project_id)
          uri = ENDPOINT.list(project_id: project_id)

          COLLECTION.from_response(get(uri))
        end
      end
    end
  end
end
