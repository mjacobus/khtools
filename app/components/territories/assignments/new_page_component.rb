# frozen_string_literal: true

class Territories::Assignments::NewPageComponent < PageComponent
  include TerritoryAttributesConcern
  has :territory
  has :assignment

  def form
    Territories::Assignments::FormComponent.new(
      territory: territory,
      assignment: territory.assignments.build
    )
  end

  private

  def breadcrumb
    @breadcrumb ||= Territories::Assignments::BreadcrumbComponent.new(territory: territory)
  end
end
