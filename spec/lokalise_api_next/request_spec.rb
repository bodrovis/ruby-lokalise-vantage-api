# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Request do
  subject(:requester) { requester_class.new(connection) }

  let(:requester_class) do
    Class.new do
      include LokaliseApiNext::Request

      def initialize(connection)
        @connection = connection
      end

      private

      attr_reader :connection
    end
  end

  let(:connection) { instance_double(HTTPX::Session) }

  describe '#get' do
    it 'performs a request and parses the response' do
      response = instance_double(
        HTTPX::Response,
        status: 200,
        body: '{"data":{"projectId":"123"}}'
      )

      allow(connection)
        .to receive(:get)
        .with('/projects/123', params: { limit: 10 })
        .and_return(response)

      result = requester.send(
        :get,
        '/projects/123',
        params: { limit: 10 }
      )

      expect(result).to eq(
        'data' => { 'projectId' => '123' }
      )
    end

    it 'returns nil for an empty response body' do
      response = instance_double(
        HTTPX::Response,
        status: 204,
        body: ''
      )

      allow(connection).to receive(:get).and_return(response)

      expect(requester.send(:get, '/projects/123')).to be_nil
    end
  end
end
