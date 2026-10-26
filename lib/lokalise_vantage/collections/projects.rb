# frozen_string_literal: true

module LokaliseVantage
  module Collections
    # Represents a collection of Vantage projects.
    class Projects < Base
      include LokaliseVantage::Concerns::Paginated

      MODEL = Models::Project
    end
  end
end
