# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a file upload in a Vantage project.
    class Upload < Base
      attributes %i[
        upload_id
        batch_id
        file_name
        size
        created_at
        status
        word_count
        locale
        item_id
        error
      ]
    end
  end
end
