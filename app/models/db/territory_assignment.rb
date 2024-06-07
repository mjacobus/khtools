# frozen_string_literal: true

class Db::TerritoryAssignment < ApplicationRecord
  belongs_to :territory
  belongs_to :assignee, class_name: 'Publisher'
  belongs_to :campaign, class_name: 'PreachingCampaign', optional: true

  default_scope -> { order(assigned_at: :desc) }
  scope :with_dependencies, -> { includes(%i[assignee territory]) }

  validates :assigned_at, presence: true

  def returned?
    returned_at.present?
  end

  def return
    self.returned_at = Time.zone.now
    save!
  end
end
