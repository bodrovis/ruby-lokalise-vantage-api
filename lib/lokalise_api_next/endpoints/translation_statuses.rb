# frozen_string_literal: true

module LokaliseApiNext
  module Endpoints
    # Builds paths for translation status operations.
    class TranslationStatuses < Base
      MEMBER_PATH = '/projects/{project_id}/translation-statuses/{import_id}'

      class << self
        def fetch(project_id:, import_id:)
          build_path(
            MEMBER_PATH,
            project_id: project_id,
            import_id: import_id
          )
        end
      end
    end
  end
end
