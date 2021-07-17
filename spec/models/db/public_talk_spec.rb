# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PublicTalk, type: :model do
  subject(:talk) { factories.public_talks.build }

  let(:talks) { factories.public_talks }

  it { is_expected.to validate_presence_of(:congregation) }
  it { is_expected.to validate_presence_of(:speaker) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:theme) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

  context 'when legacy is true' do
    before { talk.legacy = true }

    it { is_expected.not_to validate_presence_of(:congregation) }
    it { is_expected.not_to validate_presence_of(:speaker) }
    it { is_expected.to validate_presence_of(:theme) }
  end

  context 'when draft is true' do
    before { talk.status = 'draft' }

    it { is_expected.not_to validate_presence_of(:congregation) }
    it { is_expected.not_to validate_presence_of(:speaker) }
    it { is_expected.not_to validate_presence_of(:theme) }
  end

  context 'when special is true' do
    before { talk.special = true }

    it { is_expected.to validate_presence_of(:congregation) }
    it { is_expected.not_to validate_presence_of(:speaker) }
    it { is_expected.to validate_presence_of(:theme) }
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
    it 'filters by theme' do
      talks.create
      talk2 = talks.create(theme: 'the-theme')

      result = described_class.filter(theme: 'the-theme')
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk2.id])
    end

    it 'filters by congregation_id' do
      talks.create

      congregation = factories.congregations.create
      talk2 = talks.create(congregation_id: congregation.id)

      result = described_class.filter(congregation_id: congregation.id)
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk2.id])
    end

    it 'filters by speaker_id' do
      talks.create

      speaker = factories.public_speakers.create
      talk2 = talks.create(speaker_id: speaker.id)

      result = described_class.filter(speaker_id: speaker.id)
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk2.id])
    end

    it 'does not apply any filter if none is passed' do
      talk1 = talks.create
      talk2 = talks.create

      result = described_class.filter({})
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk1.id, talk2.id])
    end

    it 'returns all records when filters are not present' do
      talk1 = talks.create
      talk2 = talks.create

      result = described_class.filter(speaker_id: '')
      result_ids = result.map(&:id)

      expect(result_ids).to eq([talk1.id, talk2.id])
    end

    context 'when since: param is passed' do
      let(:a) { talks.create(date: Time.zone.now) }
      let(:b) {  talks.create(date: 1.week.from_now) }
      let(:c) {  talks.create(date: 1.week.ago) }

      before do
        a
        b
        c
      end

      it 'only returns data from since argument' do
        result = described_class.filter(since: a.date.strftime('%Y-%m-%d'))

        expect(result.pluck(:id)).to eq([a.id, b.id])
      end

      it 'takes date objects' do
        result = described_class.filter(since: a.date)

        expect(result.pluck(:id)).to eq([a.id, b.id])
      end
    end
  end

  describe '.within_week' do
    let(:week) { MeetingWeek.new }

    it 'returns only talks form that week' do
      talks.create(date: 8.days.ago)
      talks.create(date: 8.days.from_now)
      a = talks.create(date: week.last_day)
      b = talks.create(date: week.first_day)

      result = described_class.within_week(week)

      expect(result.pluck(:id)).to eq([b.id, a.id])
    end
  end

  describe '#summary' do
    it 'does not raise when theme is absent' do
      talk.theme = ''

      expect(talk.summary).not_to be_nil
    end
  end
end
