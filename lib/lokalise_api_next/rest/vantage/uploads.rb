# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project upload API operations.
      # :reek:DataClump
      module Uploads
        ENDPOINT = Endpoints::Vantage::Uploads
        MODEL = Models::Vantage::UploadBatch
        COLLECTION = Collections::Vantage::Uploads

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
end
