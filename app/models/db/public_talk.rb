# frozen_string_literal: true

module Db
  class PublicTalk < ApplicationRecord
    STATUSES = %w[scheduled confirmed draft].freeze

    belongs_to :congregation, class_name: 'Congregation', optional: true
    belongs_to :speaker, class_name: 'Db::PublicSpeaker', optional: true

    default_scope -> { order(:date) }
    scope :with_dependencies, -> { includes([:congregation, { speaker: [:congregation] }]) }
    scope :since, ->(date) { where('date >= ?', date) }
    scope :scheduled, -> { where(status: 'scheduled') }
    scope :upcoming, -> { where.not(status: 'draft') }
    scope :local, -> { joins(:congregation).where(congregation: { local: true }) }

    validates :congregation, presence: { if: :congregation_required? }
    validates :speaker, presence: { if: :speaker_required? }
    validates :theme, presence: { if: :theme_required? }
    validates :date, presence: true
    validates :status, { inclusion: { in: STATUSES } }

    def theme_object
      @theme_object ||= PublicTalks::Themes.new.find(theme)
    end

    def summary
      return "#{I18n.l(date.to_date)} - #{theme_object}" if date

      theme_object.to_s
    end

    def local?
      congregation&.local?
    end

    def draft?
      status == 'draft'
    end

    def confirmed?
      status == 'confirmed'
    end

    # rubocop:disable Metrics/AbcSize
    def self.filter(params)
      query = all

      query = query.where(speaker_id: params[:speaker_id]) if params[:speaker_id].present?

      if params[:congregation_id].present?
        query = query.where(congregation_id: params[:congregation_id])
      end

      query = query.since(params[:since]) if params[:since].present?

      query = query.where(theme: params[:theme]) if params[:theme].present?

      query
    end
    # rubocop:enable Metrics/AbcSize

    def self.within_week(week = MeetingWeek.new)
      range = (week.first_day.beginning_of_day..week.last_day.end_of_day)
      where(date: range)
    end

    private

    def speaker_required?
      !(legacy? || draft? || special?)
    end

    def congregation_required?
      !(legacy? || draft?)
    end

    def theme_required?
      !draft?
    end
  end
end
