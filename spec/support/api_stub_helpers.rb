# frozen_string_literal: true

module ApiStubHelpers
  DEFAULT_OPTIONS = {
    base_url: 'https://api.lokalise.com/vantage/v1',
    status: 200,
    query: nil,
    headers: { 'Content-Type' => 'application/json' }
  }.freeze

  # Stubs a Vantage API request using a fixture or a custom response body.
  def stub_vantage_request(method:, path:, **options)
    opts = DEFAULT_OPTIONS.merge(options)

    url = "#{opts[:base_url].delete_suffix('/')}/#{path.delete_prefix('/')}"
    request = stub_request(method, url)

    request = request.with(query: opts[:query]) if opts[:query]

    body = if options.key?(:body)
             options[:body]
           else
             fixture_body(opts.fetch(:fixture))
           end

    request.to_return(
      status: opts[:status],
      body: body,
      headers: opts[:headers]
    )
  end

  private

  def fixture_body(filename)
    File.binread(File.join(__dir__, '..', 'fixtures', filename))
  end
end
