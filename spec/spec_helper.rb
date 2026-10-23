# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  skip '/spec/'
end

require 'dotenv'
Dotenv.load

require 'webmock'
require 'httpx'
require 'httpx/adapters/webmock'
require 'webmock/rspec'

require 'lokalise_vantage'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end
