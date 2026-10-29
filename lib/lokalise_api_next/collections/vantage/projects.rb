# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Represents a collection of Vantage projects.
      class Projects < Base
        include LokaliseApiNext::Concerns::Paginated

        MODEL = Models::Vantage::Project
      end
    end
  end
end
