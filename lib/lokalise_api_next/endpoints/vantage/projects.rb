# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    module Vantage
      # Builds paths for project operations.
      class Projects < Base
        COLLECTION_PATH = '/teams/{team_id}/projects'
        MEMBER_PATH = '/projects/{project_id}'

        class << self
          def list(team_id:)
            build_path(COLLECTION_PATH, team_id: team_id)
          end

          def fetch(project_id:)
            build_path(MEMBER_PATH, project_id: project_id)
          end
        end
      end
    end
  end
end
