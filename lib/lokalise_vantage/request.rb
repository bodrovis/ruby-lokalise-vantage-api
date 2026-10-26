# frozen_string_literal: true

module LokaliseVantage
  # Performs HTTP requests.
  module Request
    private

    def get(uri, params: {})
      Response.new(connection.get(uri, params: params)).body
    end
  end
end
