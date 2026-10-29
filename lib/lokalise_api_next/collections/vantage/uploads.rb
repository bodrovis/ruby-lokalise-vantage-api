# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage uploads.
      class Uploads < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::Upload
      end
    end
  end
end
