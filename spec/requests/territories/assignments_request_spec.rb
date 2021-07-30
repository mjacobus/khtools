# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::AssignmentsController, type: :request do
  before do
    login_user(admin_user)
  end

  let(:territory) { factories.territories.create(returned_at: Time.zone.now) }
  let(:publisher) { factories.publishers.create }

  describe '#create' do
    let(:params) do
      {
        assignment: { publisher_id: publisher.id }
      }
    end
    let(:perform_request) do
      post "/territories/territories/#{territory.id}/assignments", params: params
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

    it 'resets the return time' do
      freeze_time do
        expect { perform_request }.to change {
                                        territory.reload.returned_at
                                      }.from(Time.zone.now).to(nil)
      end
    end

    it 'redirects to show page' do
      perform_request

      expect(request).to redirect_to(routes.territory_path(territory))
    end
  end

  describe '#destroy' do
    let(:perform_request) { delete "/territories/territories/#{territory.id}/assignments/unassign" }

    it 'unassigns territory' do
      territory.assign_to(publisher)

      perform_request

      territory.reload
      expect(territory.assignee_id).to be(nil)
      expect(territory.assigned_at).to be(nil)
    end

    it 'redirects to show page' do
      perform_request

      expect(request).to redirect_to(routes.territory_path(territory))
    end
  end
end
