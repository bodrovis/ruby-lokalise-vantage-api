# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage project items.
      class ProjectItems < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::ProjectItem
      end
    end
  end
end
