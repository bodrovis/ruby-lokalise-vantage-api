# frozen_string_literal: true

module LokaliseVantage
  module Rest
    # Provides project API operations.
    module Projects
      ENDPOINT = Endpoints::Projects
      COLLECTION = Collections::Projects
      MODEL = COLLECTION::MODEL

      def projects(team_id, params = {})
        uri = ENDPOINT.list(team_id: team_id)

        COLLECTION.from_response(get(uri, params: params))
      end

      def project(project_id)
        uri = ENDPOINT.fetch(project_id: project_id)

        MODEL.from_response(get(uri))
      end
    end
  end
end
