# frozen_string_literal: true

class Db::PreachingCampaign < ApplicationRecord
  has_many :assignments,
           class_name: 'TerritoryAssignment',
           inverse_of: :campaign,
           foreign_key: :campaign_id,
           dependent: :restrict_with_exception

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def each_assignment(&block)
    assignments.includes(:territory, :assignee).order('territory.name').each(&block)
  end
end
