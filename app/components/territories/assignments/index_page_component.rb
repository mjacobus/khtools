# frozen_string_literal: true

class Territories::Assignments::IndexPageComponent < PageComponent
  has :territory
  has :assignments


  private

  def breadcrumb
    @breadcrumb ||= Territories::Assignments::BreadcrumbComponent.new(territory: territory)
  end
end
