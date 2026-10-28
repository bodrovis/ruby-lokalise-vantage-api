# frozen_string_literal: true

module LokaliseVantage
  module Models
    # Represents a task in a Vantage project.
    class Task < Base
      attributes %i[
        id
        public_id
        title
        type
        status
        description
        task_assignments
        due_date
        created_at
        requested_by
      ]
    end
  end
end
