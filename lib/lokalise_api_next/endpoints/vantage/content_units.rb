# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    module Vantage
      # Builds paths for project languages operations.
      class ContentUnits < Base
        COLLECTION_PATH = '/projects/{project_id}/items/{item_id}/content-units'

        class << self
          def list(project_id:, item_id:)
            build_path(COLLECTION_PATH, project_id: project_id, item_id: item_id)
          end
        end
      end
    end
  end
end
