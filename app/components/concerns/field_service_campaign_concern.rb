# frozen_string_literal: true

module FieldServiceCampaignConcern
  def attribute(name)
    "FieldService::Campaigns::Campaign#{name.to_s.classify}Component".constantize.new(campaign, attribute_name: name)
  rescue NameError => _exception
    "FieldService::Campaigns::Campaign#{name.to_s.classify.pluralize}Component".constantize.new(campaign, attribute_name: name)
  end

  def assignments_action
    link_to(t('app.links.assignments'), urls.field_service_campaign_assignments_path(campaign), class: 'btn')
  end

  def edit_action
    link_to(t('app.links.edit'), urls.edit_field_service_campaign_path(campaign), class: 'btn')
  end

  def show_action
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
