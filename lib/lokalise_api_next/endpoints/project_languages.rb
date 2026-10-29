# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    # Builds paths for project languages operations.
    class ProjectLanguages < Base
      COLLECTION_PATH = '/projects/{project_id}/languages'

      class << self
        def list(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end
      end
    end
  end
end
