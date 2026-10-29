# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    module Vantage
      # Provides project export API operations.
      module Exports
        ENDPOINT = Endpoints::Vantage::Exports
        COLLECTION = Collections::Vantage::Exports
        MODEL = COLLECTION::MODEL
        DOWNLOAD_URL_MODEL = Models::Vantage::ExportDownloadUrl

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
end
