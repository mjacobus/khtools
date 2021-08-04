# frozen_string_literal: true

class FieldService::Campaigns::IndexPageComponent < PageComponent
  attr_reader :campaigns

  def initialize(campaigns:)
    @campaigns = campaigns
    breadcrumb.add_item(t('app.links.preaching_campaigns'))
  end

  def new_link
    link_to(t('app.links.new'), urls.new_field_service_campaign_path)
  end

  def pagination
    PaginationComponent.new(campaigns, position: :bottom)
  end
end
