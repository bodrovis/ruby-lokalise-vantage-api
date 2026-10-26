# frozen_string_literal: true

require 'zeitwerk'
require 'oj'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Ruby SDK for the Lokalise Vantage API.
module LokaliseVantage
  class << self
    def client(token, params = {})
      @client = LokaliseVantage::Client.new token, params
    end
  end
end
