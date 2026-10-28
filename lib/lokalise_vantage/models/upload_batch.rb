# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a batch of staged Vantage uploads.
    class UploadBatch < Base
      attributes %i[
        batch_id
        uploads
      ]
    end
  end
end
