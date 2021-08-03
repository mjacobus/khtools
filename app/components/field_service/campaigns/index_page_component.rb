# frozen_string_literal: true

class FieldService::Campaigns::IndexPageComponent < PageComponent
  attr_reader :campaigns

  def initialize(campaigns:)
    @campaigns = campaigns
  end
end
