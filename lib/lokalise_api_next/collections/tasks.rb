# frozen_string_literal: true

module LokaliseApiNext
  module Collections
    # Paginated collection of Vantage tasks.
    class Tasks < Base
      include Concerns::Paginated

      MODEL = Models::Task
    end
  end
end
