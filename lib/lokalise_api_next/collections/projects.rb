# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    # Represents a collection of Vantage projects.
    class Projects < Base
      include LokaliseApiNext::Concerns::Paginated

      MODEL = Models::Project
    end
  end
end
