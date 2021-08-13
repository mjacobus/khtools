# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryAssignmentMigration do
  subject(:migration) { described_class.new }

  let(:territories) { factories.territories }
  let(:time) { 2.days.ago }
  let(:publisher) { factories.publishers.create }

  describe '#migrate' do
    # rubocop:disable RSpec/ExampleLength
    it 'creates territory assignemnts if they do not exist yet' do
      freeze_time do
        territories.create(assignee_id: nil)
        territory = territories.create(assignee_id: publisher.id, assigned_at: time)

        expect do
          migration.migrate
          migration.migrate
        end.to change(Db::TerritoryAssignment, :count).by(1)

        assignment = Db::TerritoryAssignment.last
        expect(assignment.assigned_at).to eq(time)
        expect(assignment.territory_id).to eq(territory.id)
        expect(assignment.assignee_id).to eq(publisher.id)
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
