# frozen_string_literal: true

module LokaliseVantage
  module Collections
    # Paginated collection of Vantage exports.
    class Exports < Base
      include Concerns::Paginated

      MODEL = Models::Export
    end
  end
end
