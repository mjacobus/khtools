# frozen_string_literal: true

namespace :one_off do
  namespace :territories do
    desc 'Backfill last territory assignment'
    task backfill_last_territory_assignment: :environment do
      service = TerritoryAssignmentService.new

      Db::Territory.find_each do |territory|
        service.update_last_assignment(territory: territory)
      end
    end
  end
end
