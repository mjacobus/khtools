# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
class PhoneListTerritoryService
  def create_spreadsheet(territory)
    spreadsheet = Axlsx::Package.new
    workbook = spreadsheet.workbook
    workbook.add_worksheet(name: territory.name) do |sheet|
      add_territory_cells(territory, sheet)
    end

    spreadsheet
  end

  private

  def add_territory_cells(territory, sheet)
    sheet.add_row([t('territory_description', name: territory.name)])
    sheet.add_row([
                    t(:phone_number),
                    t(:date_of_first_attempt),
                    t(:date_of_second_attempt),
                    t(:date_of_third_attempt),
                    t(:notes)
                  ])

    territory.phone_numbers.each do |number|
      sheet.add_row [PhoneNumber.new(number)]
    end

    sheet.merge_cells('A1:E1')
  end

  def t(key, args = {})
    I18n.t("app.phone_list_spreadsheet.#{key}", **args)
  end
end
# rubocop:enable Metrics/MethodLength
