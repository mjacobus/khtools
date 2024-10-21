# frozen_string_literal: true

# frozen_string

class Territories::Locations::IndexPageComponent < PageComponent
  has :territory
  has :locations

  private

  def breadcrumb
    @breadcrumb ||= Territories::Locations::BreadcrumbComponent.new(territory:)
  end
end
