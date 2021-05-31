# frozen_string_literal: true

module FieldService
  class CampaignAssignmentService
    def create(campaign_id:, territory_type:)
      territory_class_for(territory_type).all.each do |territory|
        Db::PreachingCampaignAssignment.create!(
          campaign_id: campaign_id,
          territory: territory
        )
      end
    end

    private

    def territory_class_for(type)
      types.fetch(type.to_sym)
    end

    def types
      {
        apartment_building_territory: Db::ApartmentBuildingTerritory,
        phone_list_territory: Db::PhoneListTerritory,
        regular_territory: Db::RegularTerritory
      }
    end
  end
end
