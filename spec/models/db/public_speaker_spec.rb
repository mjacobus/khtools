# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PublicSpeaker do
  subject(:speaker) { factories.public_speakers.build }

  it { is_expected.to validate_presence_of(:name) }

  describe 'account ownership' do
    let(:account) { factories.accounts.create }

    it { is_expected.to belong_to(:account).class_name('Db::Account') }

    it 'rejects a congregation from another account' do
      congregation = factories.congregations.create
      speaker = factories.public_speakers.build(account:, congregation:)

      expect(speaker).not_to be_valid
      expect(speaker.errors[:congregation]).to be_present
    end
  end
end
