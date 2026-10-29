# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    # Builds paths for export operations.
    class Exports < Base
      COLLECTION_PATH = '/projects/{project_id}/exports'
      MEMBER_PATH = '/projects/{project_id}/exports/{export_id}'
      DOWNLOAD_URL_PATH = '/projects/{project_id}/exports/{export_id}/download-url'

      class << self
        def list(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end

        def fetch(project_id:, export_id:)
          build_path(
            MEMBER_PATH,
            project_id: project_id,
            export_id: export_id
          )
        end

        def create(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end

        def download_url(project_id:, export_id:)
          build_path(
            DOWNLOAD_URL_PATH,
            project_id: project_id,
            export_id: export_id
          )
        end
      end
    end
  end
end
