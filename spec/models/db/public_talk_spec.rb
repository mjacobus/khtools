# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PublicTalk, type: :model do
  subject(:talk) { factories.public_talks.build }

  it { is_expected.to validate_presence_of(:congregation) }
  it { is_expected.to validate_presence_of(:speaker) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:talk) }

  context 'when legacy is true' do
    before { talk.legacy = true }

    it { is_expected.not_to validate_presence_of(:congregation) }
    it { is_expected.not_to validate_presence_of(:speaker) }
  end

  it 'persists' do
    expect { talk.save }.to change(described_class, :count).by(1)

    talk.reload

    expect(talk.speaker).to be_a(Db::PublicSpeaker)
    expect(talk.congregation).to be_a(Db::Congregation)
  end
end
