# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    # Builds paths for project upload operations.
    class Uploads < Base
      COLLECTION_PATH = '/projects/{project_id}/uploads'
      COMPLETE_PATH = '/projects/{project_id}/uploads/actions/complete'

      class << self
        def list(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end

        def stage(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end

        def complete(project_id:)
          build_path(COMPLETE_PATH, project_id: project_id)
        end
      end
    end
  end
end
