# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PublicTalk, type: :model do
  subject(:talk) { factories.public_talks.build }

  let(:talks) { factories.public_talks }

  it { is_expected.to validate_presence_of(:congregation) }
  it { is_expected.to validate_presence_of(:speaker) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:theme) }

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

  describe '.since' do
    let(:a) { talks.create(date: Time.zone.now) }
    let(:b) {  talks.create(date: 1.week.from_now) }
    let(:c) {  talks.create(date: 1.week.ago) }

    before do
      a
      b
      c
    end

    it 'only returns data from since argument' do
      result = described_class.since(a.date.strftime('%Y-%m-%d'))

      expect(result.pluck(:id)).to eq([a.id, b.id])
    end

    it 'takes date objects' do
      result = described_class.since(a.date)

      expect(result.pluck(:id)).to eq([a.id, b.id])
    end
  end

  describe '.filter' do
    it 'filters by speaker_id' do
      factories.public_talks.create

      speaker = factories.public_speakers.create
      talk2 = factories.public_talks.create(speaker_id: speaker.id)

      result = described_class.filter(speaker_id: speaker.id)
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk2.id])
    end

    it 'does not apply any filter if none is passed' do
      talk1 = factories.public_talks.create
      talk2 = factories.public_talks.create

      result = described_class.filter({})
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk1.id, talk2.id])
    end

    it 'returns all records when filters are not present' do
      talk1 = factories.public_talks.create
      talk2 = factories.public_talks.create

      result = described_class.filter(speaker_id: '')
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk1.id, talk2.id])
    end
  end
end
