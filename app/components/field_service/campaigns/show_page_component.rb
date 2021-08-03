# frozen_string_literal: true

class FieldService::Campaigns::ShowPageComponent < PageComponent
  def initialize(campaign:)
    @campaign = campaign
  end
end
