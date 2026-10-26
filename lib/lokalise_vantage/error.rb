# frozen_string_literal: true

module LokaliseVantage
  # Represents an error returned by the Vantage API.
  class Error < StandardError
    attr_reader :code, :details, :status, :validation_errors

    VALIDATION_ERROR_FIELDS = %w[keyword instancePath schemaPath].freeze

    def initialize(message, code:, details: nil, status: nil)
      super(message)

      @code = code
      @details = details
      @status = status
      @validation_errors = extract_validation_errors
    end

    class << self
      def from_response(body, status:)
        raw_errors = body.is_a?(Hash) ? body['errors'] : nil

        if raw_errors.is_a?(Array)
          errors = raw_errors.filter_map { |item| parse(item, status: status) }
          return Aggregate.new(errors, status: status) unless errors.empty?
        end

        parse(body, status: status) || generic_error_for(status)
      end

      def generic_error_for(status)
        new(
          'An unknown error occurred',
          code: 'unknown_error',
          status: status,
          details: {
            'status' => status,
            'reason' => 'unexpected response format'
          }
        )
      end

      private

      def parse(value, status:)
        return unless value.is_a?(Hash)

        message = value['message']
        code = value['errorCode']

        return unless message.is_a?(String) && code.is_a?(String)

        details = value['details']

        new(
          message,
          code: code,
          details: details.is_a?(Hash) ? details : nil,
          status: status
        )
      end
    end

    def detailed_message
      result = "#{message} (Code: #{code})"
      result += " | Details: #{Oj.dump(details)}" if details
      result
    end

    private

    def extract_validation_errors
      return unless code.casecmp?('VALIDATION_ERROR')
      return unless details.is_a?(Hash)

      error_details = details['error']
      return unless error_details.is_a?(Array)

      error_details.select { |issue| validation_fields?(issue) }
    end

    # :reek:UtilityFunction
    def validation_fields?(issue)
      issue.is_a?(Hash) &&
        VALIDATION_ERROR_FIELDS.all? { |key| issue[key].is_a?(String) } &&
        issue['params'].is_a?(Hash) &&
        (!issue.key?('message') || issue['message'].is_a?(String))
    end

    # Represents multiple errors returned in a single response.
    class Aggregate < Error
      attr_reader :errors

      def initialize(errors, status:)
        @errors = errors.freeze

        super(
          "Vantage API returned #{errors.size} error(s)",
          code: 'multiple_errors',
          status: status
        )
      end
    end
  end
end
