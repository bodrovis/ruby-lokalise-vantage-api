# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project API operations.
      module Projects
        ENDPOINT = Endpoints::Vantage::Projects
        COLLECTION = Collections::Vantage::Projects
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
end
