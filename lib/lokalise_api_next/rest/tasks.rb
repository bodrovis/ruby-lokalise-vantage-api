# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    # Provides task API operations.
    module Tasks
      ENDPOINT = Endpoints::Tasks
      COLLECTION = Collections::Tasks

      def tasks(team_id, project_id, params = {})
        uri = ENDPOINT.list(team_id: team_id, project_id: project_id)

        COLLECTION.from_response(get(uri, params: params))
      end
    end
  end
end
