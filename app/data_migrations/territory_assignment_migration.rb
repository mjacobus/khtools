# frozen_string_literal: true

class TerritoryAssignmentMigration
  def migrate
    @migration_time = Time.zone.now

    Db::Territory.find_each do |territory|
      create_assignments(territory) if territory.assigned?
    end
  end

  private

  def create_assignments(territory)
    unless assignment_exist?(territory)
      territory.assignments.create!(
        assignee_id: territory.assignee_id,
        assigned_at: territory.assigned_at || @migration_time
      )
    end
  end

  def assignment_exist?(territory)
    territory.assignments.exists?(assigned_at: territory.assigned_at)
  end
end
