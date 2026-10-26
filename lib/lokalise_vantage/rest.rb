# frozen_string_literal: true

module LokaliseVantage
  # Combines API operations and HTTP functionality.
  module Rest
    include Connection
    include Request

    include Projects
  end
end
