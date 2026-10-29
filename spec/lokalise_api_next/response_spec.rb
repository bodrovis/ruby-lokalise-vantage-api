# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Response do
  describe '#body' do
    it 'parses a successful JSON response' do
      response = instance_double(
        HTTPX::Response,
        status: 200,
        body: '{"data":{"projectId":"123"}}'
      )

      body = described_class.new(response).body

      expect(body).to eq('data' => { 'projectId' => '123' })
    end

    it 'returns nil for an empty response body' do
      response = instance_double(
        HTTPX::Response,
        status: 204,
        body: ''
      )

      expect(described_class.new(response).body).to be_nil
    end

    it 'raises a parse error for invalid JSON in a successful response' do
      response = instance_double(
        HTTPX::Response,
        status: 200,
        body: '<html>Unexpected response</html>'
      )

      expect { described_class.new(response).body }
        .to raise_error(Oj::ParseError)
    end

    it 'raises an API error for invalid JSON in an unsuccessful response' do
      response = instance_double(
        HTTPX::Response,
        status: 502,
        body: '<html>Bad Gateway</html>'
      )

      expect { described_class.new(response).body }
        .to raise_error(LokaliseApiNext::Error) { |error|
          expect(error.code).to eq('unknown_error')
          expect(error.status).to eq(502)
        }
    end

    it 'parses a structured API error' do
      response = instance_double(
        HTTPX::Response,
        status: 422,
        body: '{"message":"Invalid request","errorCode":"VALIDATION_ERROR"}'
      )

      expect { described_class.new(response).body }
        .to raise_error(LokaliseApiNext::Error) { |error|
          expect(error.message).to eq('Invalid request')
          expect(error.code).to eq('VALIDATION_ERROR')
          expect(error.status).to eq(422)
        }
    end
  end
end
