# frozen_string_literal: true

module ControllerSpecHelper
  def self.included(base)
    base.class_eval do
      let(:regular_user) { User.new(id: 1, enabled: true, master: false) }
      let(:current_user) { regular_user }
      let(:admin_user) { User.new(id: 2, enabled: true, master: true) }
      let(:skip_login) { false }

      before do
        login_user(current_user) unless skip_login
      end
    end
  end

  def login_user(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
