# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    # Paginated collection of Vantage project items.
    class ProjectItems < Base
      include Concerns::Paginated

      MODEL = Models::ProjectItem
    end
  end
end
