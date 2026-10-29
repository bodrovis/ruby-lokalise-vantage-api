# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    module Vantage
      # Paginated collection of Vantage tasks.
      class Tasks < Base
        include Concerns::Paginated

        MODEL = Models::Vantage::Task
      end
    end
  end
end
