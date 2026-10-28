# frozen_string_literal: true

module LokaliseVantage
  module Rest
    # Provides project import API operations.
    module Imports
      ENDPOINT = Endpoints::Imports
      MODEL = Models::Import

      def create_import(project_id, params)
        uri = ENDPOINT.create(project_id: project_id)

        MODEL.from_response(post(uri, body: params))
      end
    end
  end
end
