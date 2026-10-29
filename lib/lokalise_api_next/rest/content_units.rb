# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    # Provides project API operations.
    module ContentUnits
      ENDPOINT = Endpoints::ContentUnits
      COLLECTION = Collections::ContentUnits

      def content_units(project_id, item_id, params = {})
        uri = ENDPOINT.list(project_id: project_id, item_id: item_id)

        COLLECTION.from_response(get(uri, params: params))
      end
    end
  end
end
