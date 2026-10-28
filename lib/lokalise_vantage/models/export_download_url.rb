# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a download URL for a completed Vantage export.
    class ExportDownloadUrl < Base
      attributes %i[download_url]
    end
  end
end
