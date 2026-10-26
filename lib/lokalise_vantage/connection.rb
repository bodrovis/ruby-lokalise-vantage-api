# frozen_string_literal: true

require 'httpx'

module LokaliseVantage
  # Configures HTTP connections to the Vantage API.
  module Connection
    def close
      connection.close
    end

    private

    attr_reader :connection

    def initialize_connection
      options = {
        origin: api_host,
        base_path: base_path,
        headers: connection_headers
      }

      timeouts = connection_timeouts
      options[:timeout] = timeouts unless timeouts.empty?

      session = connection_plugins.reduce(HTTPX) do |httpx, plugin|
        httpx.plugin(plugin)
      end

      session = session.with(**options)
      session = session.with_proxy(uri: proxy) if proxy

      @connection = session
    end

    def connection_plugins
      plugins = [:retries]
      plugins << :persistent if persistent
      plugins << :proxy if proxy

      plugins
    end

    def connection_headers
      {
        'Accept' => 'application/json',
        'User-Agent' => "lokalise-vantage/#{LokaliseVantage::VERSION}",
        token_header => token
      }
    end

    def connection_timeouts
      {
        connect_timeout: open_timeout,
        request_timeout: timeout
      }.compact
    end
  end
end
