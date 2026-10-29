# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Error do
  describe '.from_response' do
    let(:status) { 422 }

    def parse(body)
      described_class.from_response(body, status: status)
    end

    context 'with a single API error' do
      let(:body) do
        {
          'message' => 'Invalid request',
          'errorCode' => 'VALIDATION_ERROR',
          'details' => { 'field' => 'name' }
        }
      end

      it 'creates an API error with all attributes' do
        error = parse(body)

        expect(error).to be_a(described_class)
        expect(error.message).to eq('Invalid request')
        expect(error.code).to eq('VALIDATION_ERROR')
        expect(error.status).to eq(422)
        expect(error.details).to eq('field' => 'name')
      end

      it 'accepts an error without details' do
        body.delete('details')

        error = parse(body)

        expect(error.details).to be_nil
      end

      it 'ignores details that are not a hash' do
        body['details'] = ['unexpected']

        error = parse(body)

        expect(error.details).to be_nil
      end

      it 'preserves nested error details' do
        body['details'] = {
          'errors' => [
            { 'field' => 'name', 'reason' => 'required' }
          ]
        }

        error = parse(body)

        expect(error).not_to be_a(described_class::Aggregate)
        expect(error.details['errors'].size).to eq(1)
        expect(error.validation_errors).to be_nil
      end
    end

    context 'with multiple API errors' do
      let(:body) do
        {
          'errors' => [
            {
              'message' => 'First error',
              'errorCode' => 'VALIDATION_ERROR'
            },
            {
              'message' => 'Second error',
              'errorCode' => 'NOT_FOUND',
              'details' => { 'resource' => 'project' }
            }
          ]
        }
      end

      it 'creates an aggregate error' do
        error = parse(body)

        expect(error).to be_a(described_class::Aggregate)
        expect(error.message).to eq('Vantage API returned 2 error(s)')
        expect(error.code).to eq('multiple_errors')
        expect(error.status).to eq(422)
      end

      it 'preserves individual errors' do
        error = parse(body)

        expect(error.errors.size).to eq(2)
        expect(error.errors).to all(be_a(described_class))
        expect(error.errors.map(&:code)).to eq(%w[VALIDATION_ERROR NOT_FOUND])
        expect(error.errors.last.details).to eq('resource' => 'project')
      end

      it 'freezes the aggregate errors array' do
        error = parse(body)

        expect(error.errors).to be_frozen
      end

      it 'ignores unrecognized errors in the array' do
        body['errors'] << { 'message' => 'Missing error code' }
        body['errors'] << nil

        error = parse(body)

        expect(error.errors.size).to eq(2)
      end

      it 'creates an aggregate even if only one error is recognized' do
        body['errors'] = [
          { 'message' => 'Invalid request', 'errorCode' => 'BAD_REQUEST' },
          { 'unexpected' => true }
        ]

        error = parse(body)

        expect(error).to be_a(described_class::Aggregate)
        expect(error.errors.size).to eq(1)
      end

      it 'returns a generic error when the array is empty' do
        body['errors'] = []

        error = parse(body)

        expect(error.code).to eq('unknown_error')
      end

      it 'returns a generic error when all errors are invalid' do
        body['errors'] = [nil, 'invalid', { 'message' => 'Missing code' }]

        error = parse(body)

        expect(error.code).to eq('unknown_error')
      end
    end

    context 'with validation errors' do
      let(:valid_issue) do
        {
          'keyword' => 'required',
          'instancePath' => '/name',
          'schemaPath' => '#/required',
          'message' => 'Required property is missing',
          'params' => { 'missingProperty' => 'name' }
        }
      end

      let(:body) do
        {
          'message' => 'Validation failed',
          'errorCode' => 'VALIDATION_ERROR',
          'details' => { 'error' => [valid_issue] }
        }
      end

      it 'extracts recognized validation issues' do
        error = parse(body)

        expect(error.validation_errors).to eq([valid_issue])
      end

      it 'accepts validation issues without a message' do
        valid_issue.delete('message')

        error = parse(body)

        expect(error.validation_errors).to eq([valid_issue])
      end

      it 'filters out malformed validation issues' do
        body['details']['error'] += [
          nil,
          'invalid',
          { 'keyword' => 'required' },
          valid_issue.merge('params' => 'invalid'),
          valid_issue.merge('message' => 123),
          valid_issue.merge('instancePath' => nil)
        ]

        error = parse(body)

        expect(error.validation_errors).to eq([valid_issue])
        expect(error.details['error'].size).to eq(7)
      end

      it 'recognizes lowercase validation error codes' do
        body['errorCode'] = 'validation_error'

        error = parse(body)

        expect(error.validation_errors).to eq([valid_issue])
      end

      it 'does not extract validation issues from other error types' do
        body['errorCode'] = 'BAD_REQUEST'

        error = parse(body)

        expect(error.validation_errors).to be_nil
      end

      it 'returns nil when validation details are missing' do
        body.delete('details')

        error = parse(body)

        expect(error.validation_errors).to be_nil
      end

      it 'returns nil when validation details have the wrong structure' do
        body['details'] = { 'error' => 'not an array' }

        error = parse(body)

        expect(error.validation_errors).to be_nil
      end

      it 'returns an empty array when no validation issues are recognized' do
        body['details']['error'] = [{ 'unexpected' => true }]

        error = parse(body)

        expect(error.validation_errors).to eq([])
      end
    end

    context 'with unexpected response formats' do
      [nil, '', 'Internal Server Error', [], 42, true].each do |body|
        it "handles #{body.inspect} without crashing" do
          error = parse(body)

          expect(error).to be_a(described_class)
          expect(error.code).to eq('unknown_error')
          expect(error.status).to eq(422)
        end
      end

      it 'handles a missing errorCode' do
        error = parse('message' => 'Invalid request')

        expect(error.code).to eq('unknown_error')
      end

      it 'rejects errorCode with an invalid type' do
        error = parse('message' => 'Invalid request', 'errorCode' => 123)

        expect(error.code).to eq('unknown_error')
      end

      it 'rejects a non-string message' do
        error = parse('message' => nil, 'errorCode' => 'BAD_REQUEST')

        expect(error.code).to eq('unknown_error')
      end

      it 'includes fallback details' do
        error = parse(nil)

        expect(error.details).to eq(
          'status' => 422,
          'reason' => 'unexpected response format'
        )
      end
    end
  end

  describe '.generic_error_for' do
    it 'creates an unknown error for the given status' do
      error = described_class.generic_error_for(503)

      expect(error.message).to eq('An unknown error occurred')
      expect(error.code).to eq('unknown_error')
      expect(error.status).to eq(503)
    end
  end

  describe '#detailed_message' do
    it 'includes the message and error code' do
      error = described_class.new('Not found', code: 'NOT_FOUND', status: 404)

      expect(error.message).to eq('Not found')
      expect(error.detailed_message).to eq('Not found (Code: NOT_FOUND)')
    end

    it 'includes serialized details when present' do
      error = described_class.new(
        'Invalid request',
        code: 'BAD_REQUEST',
        details: { 'field' => 'name' }
      )

      expect(error.detailed_message).to include('Details: {"field":"name"}')
    end
  end
end
