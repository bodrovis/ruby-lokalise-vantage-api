# frozen_string_literal: true

module LokaliseVantage
  module Collections
    # Paginated collection of Vantage segments.
    class Segments < Base
      include Concerns::Paginated

      MODEL = Models::Segment
    end
  end
end
