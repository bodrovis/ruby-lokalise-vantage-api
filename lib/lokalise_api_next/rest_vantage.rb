# frozen_string_literal: true

module LokaliseApiNext
  # Combines Vantage API operations and HTTP functionality.
  module RestVantage
    include Connection
    include Request

    include Rest::Vantage::ContentUnits
    include Rest::Vantage::Exports
    include Rest::Vantage::Imports
    include Rest::Vantage::Projects
    include Rest::Vantage::ProjectItems
    include Rest::Vantage::ProjectLanguages
    include Rest::Vantage::Segments
    include Rest::Vantage::Tasks
    include Rest::Vantage::TranslationStatuses
    include Rest::Vantage::Uploads
  end
end
