# frozen_string_literal: true

module LokaliseVantage
  module Endpoints
    # Builds paths for project languages operations.
    class ProjectItems < Base
      COLLECTION_PATH = '/projects/{project_id}/items'

      class << self
        def list(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end
      end
    end
  end
end
