# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldService::CampaignAssignments::AssignButtonsComponent, type: :component do
  subject(:component) { described_class.new(campaign) }

  let(:campaign) { factories.preaching_campaigns.build }

  it 'renders' do
    expect(component.render?).to be true
  end
end
