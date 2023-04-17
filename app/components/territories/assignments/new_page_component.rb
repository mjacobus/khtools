# frozen_string_literal: true

class Territories::Assignments::NewPageComponent < PageComponent
  include TerritoryAttributesConcern
  has :territory

  private

  def breadcrumb
    @breadcrumb ||= Territories::Assignments::BreadcrumbComponent.new(territory: territory)
  end
end
