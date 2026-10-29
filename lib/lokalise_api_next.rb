# frozen_string_literal: true

require 'zeitwerk'
require 'oj'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Ruby SDK for the Lokalise Vantage API.
module LokaliseApiNext
  class << self
    def client(token, params = {})
      @client = LokaliseApiNext::Client.new token, params
    end
  end
end
