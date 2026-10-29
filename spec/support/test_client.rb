# frozen_string_literal: true

module ClientHelpers
  # Creates a Vantage API client for tests.
  def test_client_vantage(token = nil, params = {})
    LokaliseApiNext.client_vantage(
      token || ENV.fetch('LOKALISE_VANTAGE_TOKEN', nil),
      params
    )
  end
end
