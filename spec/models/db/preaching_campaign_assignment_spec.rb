# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PreachingCampaignAssignment, type: :model do
  subject(:assignment) { factories.preaching_campaign_assignments.build }

  it {
    expect(assignment).to belong_to(:campaign)
      .class_name('Db::PreachingCampaign').required
  }

  it {
    expect(assignment).to belong_to(:territory)
      .class_name('Db::Territory').required
  }

  it {
    expect(assignment).to belong_to(:assignee)
      .class_name('Db::Publisher').optional
  }
end
