# frozen_string_literal: true

class TerritoryAssignmentMigration
  def migrate
    Db::Territory.find_each do |territory|
      if territory.assigned?
        create_assignments(territory)
      end
    end
  end

  private

  def create_assignments(territory)
    unless assignment_exist?(territory)
      territory.assignments.create!(
        assignee_id: territory.assignee_id,
        assigned_at: territory.assigned_at
      )
    end
  end

  def assignment_exist?(territory)
    territory.assignments.exists?(assigned_at: territory.assigned_at)
  end
end
