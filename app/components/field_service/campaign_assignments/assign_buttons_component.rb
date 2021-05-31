# frozen_string_literal: true

class FieldService::CampaignAssignments::AssignButtonsComponent < ApplicationComponent
  def initialize(campaign, service: FieldService::CampaignAssignmentService.new)
    @campaign = campaign
    @service = service
    @exist_cache = {}
    super(campaign: campaign, service: service)
  end

  def exist?(territory_type:)
    @exist_cache[territory_type.to_sym] ||= @service.exist?(
      territory_type: territory_type,
      campaign_id: @campaign.id
    )
  end

  def create_link(type)
    urls.create_field_service_campaign_assignments_path(@campaign, territory_type: type)
  end

  def button_label(type)
    t("activerecord.models.db/#{type}")
  end

  def render?
    territory_types.any? do |type|
      !exist?(territory_type: type)
    end
  end

  def confirm_message(type)
    human_name = t("activerecord.models.db/#{type}")
    t('app.messages.confirm_campaign_assignment', territory_type: human_name)
  end

  def territory_types
    %i[
      regular_territory
      apartment_building_territory
      phone_list_territory
    ]
  end
end
