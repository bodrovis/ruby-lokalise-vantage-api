# frozen_string_literal: true

module LokaliseApiNext
  module Rest
    # Provides project API operations.
    module Segments
      ENDPOINT = Endpoints::Segments
      COLLECTION = Collections::Segments
      MODEL = COLLECTION::MODEL

      def segments(project_id, content_unit_id, params = {})
        uri = ENDPOINT.list(project_id: project_id, content_unit_id: content_unit_id)

        COLLECTION.from_response(get(uri, params: params))
      end

      def update_segment(project_id, segment_id, params)
        uri = ENDPOINT.update(project_id: project_id, segment_id: segment_id)

        MODEL.from_response(patch(uri, body: params))
      end
    end
  end
end
