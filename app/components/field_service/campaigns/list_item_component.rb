# frozen_string_literal: true

class FieldService::Campaigns::ListItemComponent < ApplicationComponent
  include FieldServiceCampaignConcern

  has :campaign

  private

  def actions
    [
      assignments_action,
      edit_action,
      delete_action
    ]
  end

  def assignments_action
    link_to(t('app.links.assignments'), urls.field_service_campaign_assignments_path(campaign), class: 'btn')
  end

  def edit_action
    link_to(t('app.links.view'), urls.field_service_campaign_path(campaign), class: 'btn')
  end

  def delete_action
    link_to(
      t('app.links.delete'),
      urls.field_service_campaign_path(campaign),
      data: { method: :delete, confirm: t('app.messages.confirm_delete') },
      class: 'btn'
    )
  end
end
