# frozen_string_literal: true

module LokaliseVantage
  module Rest
    # Provides project export API operations.
    module Exports
      ENDPOINT = Endpoints::Exports
      COLLECTION = Collections::Exports
      MODEL = COLLECTION::MODEL
      DOWNLOAD_URL_MODEL = Models::ExportDownloadUrl

      def exports(project_id, params = {})
        uri = ENDPOINT.list(project_id: project_id)

        COLLECTION.from_response(get(uri, params: params))
      end

      def export(project_id, export_id)
        uri = ENDPOINT.fetch(project_id: project_id, export_id: export_id)

        MODEL.from_response(get(uri))
      end

      def create_export(project_id, params = {})
        uri = ENDPOINT.create(project_id: project_id)

        MODEL.from_response(post(uri, body: params))
      end

      def export_download_url(project_id, export_id)
        uri = ENDPOINT.download_url(project_id: project_id, export_id: export_id)

        DOWNLOAD_URL_MODEL.from_response(get(uri))
      end
    end
  end
end
