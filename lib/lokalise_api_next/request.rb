# frozen_string_literal: true

module LokaliseApiNext
  # Performs HTTP requests.
  module Request
    private

    def get(uri, params: {})
      Response.new(connection.get(uri, params: params)).body
    end

    def post(uri, body:)
      response = connection.post(
        uri,
        body: Oj.dump(body, mode: :strict),
        headers: { 'Content-Type' => 'application/json' }
      )

      Response.new(response).body
    end

    def patch(uri, body:)
      response = connection.patch(
        uri,
        body: Oj.dump(body, mode: :strict),
        headers: { 'Content-Type' => 'application/json' }
      )

      Response.new(response).body
    end
  end
end
