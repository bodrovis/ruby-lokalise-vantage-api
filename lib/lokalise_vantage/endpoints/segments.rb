# frozen_string_literal: true

module LokaliseVantage
  module Endpoints
    # Builds paths for segment operations.
    class Segments < Base
      COLLECTION_PATH = '/projects/{project_id}/content-units/{content_unit_id}/segments'
      MEMBER_PATH = '/projects/{project_id}/segments/{segment_id}'

      def list(project_id:, content_unit_id:)
        build_path(
          COLLECTION_PATH,
          project_id: project_id,
          content_unit_id: content_unit_id
        )
      end

      def update(project_id:, segment_id:)
        build_path(
          MEMBER_PATH,
          project_id: project_id,
          segment_id: segment_id
        )
      end
    end
  end
end
