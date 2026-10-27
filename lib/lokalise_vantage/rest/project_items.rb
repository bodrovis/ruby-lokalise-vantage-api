# frozen_string_literal: true

module LokaliseVantage
  module Rest
    # Provides project API operations.
    module ProjectItems
      ENDPOINT = Endpoints::ProjectItems
      COLLECTION = Collections::ProjectItems

      def project_items(project_id, params = {})
        uri = ENDPOINT.list(project_id: project_id)

        COLLECTION.from_response(get(uri, params: params))
      end
    end
  end
end
