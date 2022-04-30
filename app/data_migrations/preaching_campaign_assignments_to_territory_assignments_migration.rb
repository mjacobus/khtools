# frozen_string_literal: true

# rubocop diasable: Rails/Output
class PreachingCampaignAssignmentsToTerritoryAssignmentsMigration
  def migrate
    Db::PreachingCampaignAssignment.transaction do
      assignments.find_each do |assignment|
        convert(assignment)
      end
    end
  end

  private

  def assignments
    Db::PreachingCampaignAssignment.where.not(assignee_id: nil).order(assigned_at: :asc)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def convert(assignment)
    ta = Db::TerritoryAssignment.create!(
      territory_id: assignment.territory_id,
      campaign_id: assignment.campaign_id,
      assignee_id: assignment.assignee_id,
      assigned_at: assignment.assigned_at,
      returned_at: assignment.returned_at
    )

    territory = ta.territory

    if overwrite_assignment?(territory, ta)
      if ta.returned_at
        territory.assignee_id = nil
        territory.assigned_at = nil
      else
        territory.assignee_id = ta.assignee_id
        territory.assigned_at = ta.assigned_at
      end
    end

    territory.save!
  rescue ActiveRecord::RecordInvalid => exception
    raise "#{exception.record.class} has errors: #{exception.record.errors.to_h}"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def overwrite_assignment?(territory, assignment)
    last_territory_movement = territory.assigned_at
    last_assignment_movement = assignment.returned_at || assignment.assigned_at

    unless last_territory_movement
      return true
    end

    if last_territory_movement < last_assignment_movement
      return true
    end

    false
  end
end
