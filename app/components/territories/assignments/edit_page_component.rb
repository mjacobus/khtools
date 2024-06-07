# frozen_string_literal: true

class Territories::Assignments::EditPageComponent < PageComponent
  include TerritoryAttributesConcern
  has :territory
  has :assignment

  def form
    Territories::Assignments::FormComponent.new(
      territory:,
      assignment:
    )
  end

  private

  def breadcrumb
    @breadcrumb ||= Territories::Assignments::BreadcrumbComponent.new(territory:)
  end
end
