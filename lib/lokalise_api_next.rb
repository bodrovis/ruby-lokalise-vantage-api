# frozen_string_literal: true

require 'zeitwerk'
require 'oj'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Ruby SDK for Lokalise APIs.
module LokaliseApiNext
  class << self
    def client_vantage(token, params = {})
      ClientVantage.new(token, params)
    end
  end
end
