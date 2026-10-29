# frozen_string_literal: true

module LokaliseApiNext
  # Client for interacting with the Vantage API.
  class ClientVantage < BaseClient
    include LokaliseApiNext::RestVantage

    BASE_PATH = '/vantage/v1'
  end
end
