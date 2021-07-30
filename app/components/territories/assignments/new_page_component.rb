# frozen_string_literal: true

class Territories::Assignments::NewPageComponent < PageComponent
  include TerritoryAttributesConcern

  has :territory

  def publishers
    Db::Publisher.all.pluck(:name, :id)
  end

  def target_url
    urls.territory_assignments_path(territory)
  end
end
