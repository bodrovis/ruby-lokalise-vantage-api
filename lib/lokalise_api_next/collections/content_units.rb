# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    # Paginated collection of Vantage content units.
    class ContentUnits < Base
      include Concerns::Paginated

      MODEL = Models::ContentUnit
    end
  end
end
