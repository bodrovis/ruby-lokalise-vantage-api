# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    module Vantage
      # Builds paths for task operations.
      class Tasks < Base
        COLLECTION_PATH = '/teams/{team_id}/projects/{project_id}/tasks'

        class << self
          def list(team_id:, project_id:)
            build_path(
              COLLECTION_PATH,
              team_id: team_id,
              project_id: project_id
            )
          end
        end
      end
    end
  end
end
