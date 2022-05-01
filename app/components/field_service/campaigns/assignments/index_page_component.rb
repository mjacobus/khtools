# frozen_string_literal: true

class FieldService::Campaigns::Assignments::IndexPageComponent < PageComponent
  has :campaign
  has :assignments

  def pagination
    PaginationComponent.new(assignments, position: :bottom)
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.preaching_campaigns'), urls.preaching_campaigns_path)
    breadcrumb.add_item(campaign.name, urls.to(campaign))
    breadcrumb.add_item(t('app.titles.assignments'))
  end
end
