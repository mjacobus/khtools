# frozen_string_literal: true

class Territories::Assignments::FormComponent < PageComponent
  has :territory
  has :assignment

  def publishers
    current_account.publishers.pluck(:name, :id)
  end

  def preaching_campaigns
    current_account.preaching_campaigns.order(created_at: :desc).pluck(:name, :id)
  end

  def target_url
    urls.territory_assignments_path(territory)
  end
end
