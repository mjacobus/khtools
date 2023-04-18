# frozen_string_literal: true

class TerritoryAssignmentService
  AssignmentError = Class.new(StandardError)

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def assign(territory:, to:, campaign:, notes: nil)
    if territory.assigned?
      raise AssignmentError, 'Already assigned'
    end

    if to.is_a?(Db::Publisher)
      to = to.id
    end

    if campaign.is_a?(Db::PreachingCampaign)
      campaign = campaign.id
    end

    territory.assignee_id = to
    territory.assigned_at = Time.zone.now

    territory.class.transaction do
      assignment = territory.assignments.build(
        assignee_id: territory.assignee_id,
        assigned_at: territory.assigned_at,
        campaign_id: campaign,
        notes: notes
      )
      assignment.save!
      territory.last_assignment = assignment
      territory.save!
      assignment
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/ParameterLists
  def update_assignment(assignment:, campaign:, to:, notes: nil, assigned_at: nil, returned_at: nil)
    assignment = Db::TerritoryAssignment.coerce(assignment)

    assignment.assignee_id = Db::Publisher.to_id(to)
    assignment.campaign_id = Db::PreachingCampaign.to_id(campaign)
    assignment.notes = notes
    assignment.assigned_at = assigned_at
    assignment.returned_at = returned_at
    assignment.save!
    update_last_assignment(territory: assignment.territory)
  end
  # rubocop:enable Metrics/ParameterLists

  def update_last_assignment(territory:)
    assignment = territory.assignments.first
    territory.last_assignment = assignment
    territory.assignee_id = assignment.assignee_id
    territory.assigned_at = assignment.assigned_at
    territory.save!
  end

  def return_territory(territory:)
    assignments_to_return = territory.assignments.where(assignee_id: territory.assignee_id)

    territory.assignee_id = nil
    territory.assigned_at = nil

    territory.class.transaction do
      assignments_to_return.map(&:return)
      territory.save!
    end
  end
end
