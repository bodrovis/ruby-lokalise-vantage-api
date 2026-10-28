# frozen_string_literal: true

module LokaliseVantage
  module Endpoints
    # Builds paths for project import operations.
    class Imports < Base
      COLLECTION_PATH = '/projects/{project_id}/imports'

      class << self
        def create(project_id:)
          build_path(COLLECTION_PATH, project_id: project_id)
        end
      end
    end
  end
end
