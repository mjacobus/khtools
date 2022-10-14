# frozen_string_literal: true

module ControllerSpecHelper
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.included(base)
    base.class_eval do
      let(:regular_user) do
        factories.users.create(enabled: true, master: false, account: current_account)
      end
      let(:current_user) { regular_user }
      let(:admin_user) do
        factories.users.create(enabled: true, master: true, account: current_account)
      end
      let(:skip_login) { false }
      let(:current_account) { factories.accounts.create }

      before do
        unless skip_login
          login_user(current_user)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def login_user(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
