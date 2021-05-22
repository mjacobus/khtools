# frozen_string_literal: true

class ApartmentBuildingTerritoryCsvImportService
  def import_file(file)
    Db::ApartmentBuildingTerritory.transaction do
      CSV.parse(file, headers: true) do |row|
        import_row(row.to_h.symbolize_keys)
      end
    end
  end

  private

  def import_row(row)
    parent = row.delete(:territory)

    area = row.delete(:area)
    assignee = row.delete(:assignee)

    territory = Db::ApartmentBuildingTerritory.new(row)

    if area
      territory.area = Db::TerritoryArea.find_or_create_by(name: area)
    end

    if assignee
      territory.assignee = Db::Publisher.identify(assignee)
    end

    if parent
      territory.territory = Db::Territory.identify(parent)
    end

    territory.save!
  end
end
