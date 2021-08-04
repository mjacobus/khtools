# frozen_string_literal: true

module FieldServiceCampaignConcern
  def attribute(name)
    "FieldService::Campaigns::Campaign#{name.to_s.classify}Component".constantize.new(campaign, attribute_name: name)
  rescue NameError => _exception
    "FieldService::Campaigns::Campaign#{name.to_s.classify.pluralize}Component".constantize.new(campaign, attribute_name: name)
  end
end
