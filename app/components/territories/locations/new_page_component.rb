# frozen_string_literal: true

class Territories::Locations::NewPageComponent < PageComponent
  include TerritoryAttributesConcern
  has :territory
  has :location

  def form
    Territories::Locations::FormComponent.new(territory:, location:)
  end

  private

  def breadcrumb
    @breadcrumb ||= Territories::Locations::BreadcrumbComponent.new(territory:)
  end
end
