# frozen_string_literal: true

module LokaliseApiNext
  # Base client with shared HTTP configuration.
  class BaseClient
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
      @base_path = params.fetch(:base_path, self.class::BASE_PATH).dup.freeze
    end

    def configure_transport(params)
      @timeout = params[:timeout]
      @open_timeout = params[:open_timeout]
      @persistent = params.fetch(:persistent, false)
      @proxy = params[:proxy]&.dup&.freeze
    end
  end
end
