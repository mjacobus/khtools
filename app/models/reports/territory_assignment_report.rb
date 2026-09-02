# frozen_string_literal: true

module Reports
  # Data behind the S-13 form ("Registro de Designação de Território"): one row
  # per territory, listing every assignment that overlaps a service year.
  class TerritoryAssignmentReport
    # The paper form has four "assigned to" blocks per row.
    MINIMUM_COLUMNS = 4

    ALL_TYPES = 'all'

    TYPES = {
      'regular' => Db::RegularTerritory,
      'commercial' => Db::CommercialTerritory,
      'apartment_building' => Db::ApartmentBuildingTerritory,
      'phone_list' => Db::PhoneListTerritory
    }.freeze

    DEFAULT_TYPE = TYPES.fetch('regular')

    Row = Struct.new(:territory, :last_completed_at, :assignments, keyword_init: true)

    # @return [Class, nil] nil means "every type"
    def self.type_for(key)
      key = key.to_s

      if key == ALL_TYPES
        return nil
      end

      TYPES.fetch(key, DEFAULT_TYPE)
    end

    def self.type_key_for(type)
      TYPES.key(type) || ALL_TYPES
    end

    # From the oldest assignment of the account down to the current service
    # year, most recent first.
    def self.available_service_years(account)
      current = ServiceYear.current
      first = oldest_service_year(account, fallback: current)
      first = current if first.year > current.year

      first.year.upto(current.year).map { |year| ServiceYear.new(year) }.reverse
    end

    def self.oldest_service_year(account, fallback:)
      oldest = Db::TerritoryAssignment
        .reorder(nil)
        .where(territory_id: account.territories.reorder(nil).select(:id))
        .minimum(:assigned_at)

      oldest ? ServiceYear.containing(oldest) : fallback
    end

    attr_reader :service_year
    attr_reader :type

    delegate :empty?, to: :rows

    def initialize(account:, service_year: ServiceYear.current, type: DEFAULT_TYPE)
      @account = account
      @service_year = service_year
      @type = type
    end

    def rows
      @rows ||= territories.map do |territory|
        Row.new(
          territory:,
          last_completed_at: last_completions[territory.id],
          assignments: assignments_by_territory.fetch(territory.id, [])
        )
      end
    end

    def columns_count
      [MINIMUM_COLUMNS, rows.map { |row| row.assignments.size }.max.to_i].max
    end

    def type_key
      self.class.type_key_for(type)
    end

    def filename(extension = nil)
      base = I18n.t('app.reports.territory_assignments.filename')

      ["#{base}-#{service_year.label.tr('/', '-')}", extension].compact.join('.')
    end

    private

    def territories
      @territories ||= begin
        scope = @account.territories.reorder(nil)
        scope = scope.where(type: type.to_s) if type
        scope.to_a.sort_by { |territory| natural_key(territory.name) }
      end
    end

    def territory_ids
      @territory_ids ||= territories.map(&:id)
    end

    # An assignment belongs to the report when its [assigned_at, returned_at]
    # interval overlaps the service year. Open assignments have no end.
    def assignments_by_territory
      @assignments_by_territory ||= Db::TerritoryAssignment
        .where(territory_id: territory_ids)
        .where(assigned_at: ..service_year.ends_at)
        .where('returned_at IS NULL OR returned_at >= ?', service_year.starts_at)
        .includes(:assignee)
        .reorder(assigned_at: :asc, id: :asc)
        .group_by(&:territory_id)
    end

    def last_completions
      @last_completions ||= Db::TerritoryAssignment
        .reorder(nil)
        .where(territory_id: territory_ids)
        .where(returned_at: ...service_year.starts_at)
        .group(:territory_id)
        .maximum(:returned_at)
    end

    # "10" must come after "2", and numbers before names.
    def natural_key(name)
      name.to_s.downcase.scan(/\d+|\D+/).map do |part|
        part.match?(/\A\d+\z/) ? [0, part.to_i, ''] : [1, 0, part]
      end
    end
  end
end
