# frozen_string_literal: true

module Territories
  class AssignmentComponent < ApplicationComponent
    has :assignment
    has :parent

    def territory_perspective?
      parent.is_a?(Db::Territory)
    end

    def publisher_perspective?
      parent.is_a?(Db::Publisher)
    end

    def campaign_perspective?
      parent.is_a?(Db::PreachingCampaign)
    end

    def campaign_url
      if assignment.campaign
        urls.to(assignment.campaign)
      end
    end
  end
end
