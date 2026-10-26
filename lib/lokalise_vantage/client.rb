# frozen_string_literal: true

module LokaliseVantage
  # Client for interacting with the Vantage API.
  class Client
    include Rest

    attr_reader :token, :token_header, :api_host, :base_path,
                :timeout, :open_timeout, :persistent, :proxy

    def initialize(token, params = {})
      @token = token.dup.freeze

      configure_api(params)
      configure_transport(params)
      initialize_connection
    end

    private

    def configure_api(params)
      @token_header = params.fetch(:token_header, 'x-api-token').dup.freeze
      @api_host = params.fetch(:api_host, 'https://api.lokalise.com').dup.freeze
      @base_path = params.fetch(:base_path, '/vantage/v1').dup.freeze
    end

    def configure_transport(params)
      @timeout = params[:timeout]
      @open_timeout = params[:open_timeout]
      @persistent = params.fetch(:persistent, false)
      @proxy = params[:proxy]&.dup&.freeze
    end
  end
end
