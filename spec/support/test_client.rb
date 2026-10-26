# frozen_string_literal: true

module ClientHelpers
  # Creates a Vantage API client for tests.
  def test_client(token = nil, params = {})
    LokaliseVantage.client(
      token || ENV.fetch('LOKALISE_VANTAGE_TOKEN', nil),
      params
    )
  end
end
