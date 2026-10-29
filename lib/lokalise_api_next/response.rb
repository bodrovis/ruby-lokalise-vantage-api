# frozen_string_literal: true

module LokaliseApiNext
  # Parses HTTP responses and handles API errors.
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def body
      @http_response.raise_for_status if @http_response.is_a?(HTTPX::ErrorResponse)

      parsed_body = parse_body
      status = @http_response.status

      raise Error.from_response(parsed_body, status: status) unless status.between?(200, 299)

      parsed_body
    end

    private

    def parse_body
      raw = @http_response.body.to_s
      return nil if raw.empty?

      Oj.load(raw, mode: :strict)
    rescue Oj::ParseError
      raise if @http_response.status.between?(200, 299)

      raw
    end
  end
end
