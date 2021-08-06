# frozen_string_literal: true

class FieldService::Campaigns::FormPageComponent < PageComponent
  has :campaign

  def target_url
    if campaign.id
      return urls.field_service_campaign_path(campaign)
    end

    urls.field_service_campaigns_path
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.preaching_campaigns'), urls.public_talks_speakers_path)

    if campaign.id
      breadcrumb.add_item(
        campaign.name,
        urls.public_talks_speaker_path(campaign)
      )
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end
end
