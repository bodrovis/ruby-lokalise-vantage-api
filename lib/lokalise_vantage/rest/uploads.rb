# frozen_string_literal: true

module LokaliseVantage
  module Rest
    # Provides project upload API operations.
    # :reek:DataClump
    module Uploads
      ENDPOINT = Endpoints::Uploads
      MODEL = Models::UploadBatch
      COLLECTION = Collections::Uploads

      def uploads(project_id, params = {})
        uri = ENDPOINT.list(project_id: project_id)

        COLLECTION.from_response(get(uri, params: params))
      end

      def stage_uploads(project_id, params)
        uri = ENDPOINT.stage(project_id: project_id)

        MODEL.from_response(post(uri, body: params))
      end

      def complete_uploads(project_id, params)
        uri = ENDPOINT.complete(project_id: project_id)

        post(uri, body: params)
      end
    end
  end
end
