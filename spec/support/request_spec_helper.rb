# frozen_string_literal: true

module RequestSpecHelper
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.included(base)
    base.class_eval do
      let(:avatar) do
        'https://lh3.googleusercontent.com/-QTW2nlN4-NU/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucnAmijxFSFomGTNwgC-PRjxi5qPVg/s96-c/photo.jpgend'
      end
      let(:regular_user) { User.new(id: 1, enabled: true, master: false, avatar: avatar) }
      let(:current_user) { regular_user }
      let(:admin_user) { User.new(id: 2, enabled: true, master: true, avatar: avatar) }
      let(:skip_login) { false }
      let(:factories) { TestFactories.new }

      before do
        unless skip_login
          login_user(current_user)
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def login_user(user)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
  end

  def grant_access(user, actions: ['*'])
    controller = described_class.to_s.underscore.sub('_controller', '')
    actions.each do |action|
      user.grant_controller_access(controller, action: action)
    end
  end
end
