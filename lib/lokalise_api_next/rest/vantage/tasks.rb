# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides task API operations.
      module Tasks
        ENDPOINT = Endpoints::Vantage::Tasks
        COLLECTION = Collections::Vantage::Tasks

        def tasks(team_id, project_id, params = {})
          uri = ENDPOINT.list(team_id: team_id, project_id: project_id)

          COLLECTION.from_response(get(uri, params: params))
        end
      end
    end
  end
end
