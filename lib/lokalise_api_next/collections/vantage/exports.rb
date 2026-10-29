# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage exports.
      class Exports < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::Export
      end
    end
  end
end
