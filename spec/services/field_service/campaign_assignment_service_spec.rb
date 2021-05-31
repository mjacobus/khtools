# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldService::CampaignAssignmentService do
  subject(:service) { described_class.new }

  describe '#create' do
    let(:campaign) { factories.preaching_campaigns.create }
    let(:types) do
      {
        apartment_building_territory: factories.apartment_building_territories.create,
        phone_list_territory: factories.phone_list_territories.create,
        regular_territory: factories.territories.create
      }
    end

    it 'creates assignments for each one of the territory types' do
      types.each do |type, territory|
        expect { service.create(territory_type: type, campaign_id: campaign.id) }
          .to change(Db::PreachingCampaignAssignment, :count).by(1)

        last = Db::PreachingCampaignAssignment.order(:id).last

        expect(last.campaign_id).to eq(campaign.id)
        expect(last.territory).to eq(territory)
      end
    end
  end
end
