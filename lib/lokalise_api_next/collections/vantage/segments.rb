# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage segments.
      class Segments < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::Segment
      end
    end
  end
end
