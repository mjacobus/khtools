# frozen_string_literal: true

class TerritoryAssignmentService
  def update_last_assignment(territory:)
    territory.last_assignment = territory.assignments.first
    territory.save!
  end
end
