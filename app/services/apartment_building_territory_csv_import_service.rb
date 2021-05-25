# frozen_string_literal: true

class ApartmentBuildingTerritoryCsvImportService
  ACCEPTED_HEADERS = %i[
    name
    assignee
    building_name
    address
    area
    number_of_apartments
    primary_preaching_method
    secondary_preaching_method
    tertiary_preaching_method
    has_a_roof
    intercom_type
    letter_box_type
    notes
    territory
    apartments
  ].freeze

  def import_file(file)
    Db::ApartmentBuildingTerritory.transaction do
      CSV.parse(file, headers: true) do |row|
        import_row(row.to_h.symbolize_keys)
      end
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def import_row(row)
    row = filter_row(row)
    parent = row.delete(:territory)
    area = row.delete(:area)
    assignee = row.delete(:assignee)
    primary_preaching_method = row.delete(:primary_preaching_method)
    secondary_preaching_method = row.delete(:secondary_preaching_method)
    tertiary_preaching_method = row.delete(:tertiary_preaching_method)

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

    if primary_preaching_method
      territory.primary_preaching_method = Db::PreachingMethod.find_or_create_by(name: primary_preaching_method)
    end

    if secondary_preaching_method
      territory.secondary_preaching_method = Db::PreachingMethod.find_or_create_by(name: secondary_preaching_method)
    end

    if tertiary_preaching_method
      territory.tertiary_preaching_method = Db::PreachingMethod.find_or_create_by(name: tertiary_preaching_method)
    end

    territory.save!
  end

  def filter_row(row)
    row.select do |key, _value|
      ACCEPTED_HEADERS.include?(key)
    end
  end

  # rubocop:enable Metrics/MethodLength
end
