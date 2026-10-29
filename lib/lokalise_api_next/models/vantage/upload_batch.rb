# frozen_string_literal: true

module LokaliseApiNext
  module Models
    module Vantage
      # Represents a batch of staged Vantage uploads.
      class UploadBatch < Base
        attributes %i[
          batch_id
          uploads
        ]
      end
    end
  end
end
