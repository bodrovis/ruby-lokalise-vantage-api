# frozen_string_literal: true

module LokaliseVantage
  module Collections
    # Paginated collection of Vantage uploads.
    class Uploads < Base
      include Concerns::Paginated

      MODEL = Models::Upload
    end
  end
end
