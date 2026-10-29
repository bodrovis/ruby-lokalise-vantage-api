# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project API operations.
      module ProjectItems
        ENDPOINT = Endpoints::Vantage::ProjectItems
        COLLECTION = Collections::Vantage::ProjectItems

        def project_items(project_id, params = {})
          uri = ENDPOINT.list(project_id: project_id)

          COLLECTION.from_response(get(uri, params: params))
        end
      end
    end
  end
end
