# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::AssignmentsController do
  before do
    login_user(admin_user)
    admin_user.account = territory.account
    admin_user.save!
  end

  let(:territory) { factories.territories.create }
  let(:publisher) { factories.publishers.create }

  describe 'GET #new' do
    let(:territory) { factories.territories.create }
    let(:perform_request) { get routes.new_territory_assignment_path(territory) }

    it 'returns http success' do
      perform_request

      expect(response).to have_http_status(:success)
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Territories::Assignments::NewPageComponent.new(
        territory:,
        assignment: territory.assignments.build
      )
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe '#create' do
    let(:params) do
      {
        assignment: { assignee_id: publisher.id }
      }
    end
    let(:perform_request) do
      post routes.territory_assignments_path(territory), params:
    end

    it 'assigns a territory' do
      freeze_time do
        expect { perform_request }.to change {
                                        territory.reload.assignee_id
                                      }.from(nil).to(publisher.id)
      end
    end

    it 'sets the assignment time' do
      freeze_time do
        expect { perform_request }.to change {
                                        territory.reload.assigned_at
                                      }.from(nil).to(Time.zone.now)
      end
    end

    it 'redirects to show page' do
      perform_request

      expect(request).to redirect_to(routes.territory_path(territory))
    end
  end

  describe 'DELETE an assignment' do
    it 'deletes that assignment and redirects to the territory' do
      assignment = territory.assign_to(publisher)

      expect { delete routes.territory_assignment_path(assignment) }
        .to change(Db::TerritoryAssignment, :count).by(-1)
      expect(response).to redirect_to(routes.territory_path(territory))
      expect(territory.reload.assignee).to be_nil
    end

    it 'does not delete assignments of another territory' do
      other_territory = factories.territories.create(account: territory.account)
      assignment = other_territory.assign_to(publisher)

      delete "#{routes.territory_assignments_path(territory)}/#{assignment.id}"

      expect(response).to have_http_status(:not_found)
      expect(Db::TerritoryAssignment.exists?(assignment.id)).to be(true)
    end
  end

  describe '#destroy' do
    let(:perform_request) { delete routes.return_territory_path(territory) }

    it 'unassigns territory' do
      territory.assign_to(publisher)

      perform_request

      territory.reload
      expect(territory.assignee_id).to be_nil
      expect(territory.assigned_at).to be_nil
    end

    it 'redirects to show page' do
      perform_request

      expect(request).to redirect_to(routes.territory_path(territory))
    end
  end
end
