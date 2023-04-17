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
      territory.last_assignment = assignment
      territory.save!
      assignment
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def update_last_assignment(territory:)
    territory.last_assignment = territory.assignments.first
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
