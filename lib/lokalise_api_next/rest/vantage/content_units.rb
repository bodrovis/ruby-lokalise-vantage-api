# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project API operations.
      module ContentUnits
        ENDPOINT = Endpoints::Vantage::ContentUnits
        COLLECTION = Collections::Vantage::ContentUnits

        def content_units(project_id, item_id, params = {})
          uri = ENDPOINT.list(project_id: project_id, item_id: item_id)

          COLLECTION.from_response(get(uri, params: params))
        end
      end
    end
  end
end
