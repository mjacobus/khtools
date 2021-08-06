# frozen_string_literal: true

class Db::PreachingCampaignAssignment < ApplicationRecord
  belongs_to :campaign, class_name: 'PreachingCampaign'
  belongs_to :territory
  belongs_to :assignee, class_name: 'Publisher', optional: true

  scope :with_dependencies, -> { includes(:territory, :assignee).order('territories.name') }
end
