# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage content units.
      class ContentUnits < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::ContentUnit
      end
    end
  end
end
