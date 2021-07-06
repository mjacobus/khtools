# frozen_string_literal: true

class Db::PublicTalk < ApplicationRecord
  STATUSES = %w[scheduled confirmed draft].freeze

  belongs_to :congregation, class_name: 'Congregation', optional: true
  belongs_to :speaker, class_name: 'Db::PublicSpeaker', optional: true

  default_scope -> { order(:date) }
  scope :since, ->(date) { where('date >= ?', date) }

  validates :congregation, presence: { if: :all_fields_required? }
  validates :speaker, presence: { if: :all_fields_required? }
  validates :theme, presence: { unless: :draft? }
  validates :date, presence: true
  validates :status, { inclusion: { in: STATUSES } }

  def theme_object
    @theme_object ||= PublicTalks::Themes.new.find(theme)
  end

  def summary
    "#{I18n.l(date.to_date)} - #{theme_object}"
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

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.filter(params)
    query = all

    if params[:speaker_id].present?
      query = query.where(speaker_id: params[:speaker_id])
    end

    if params[:congregation_id].present?
      query = query.where(congregation_id: params[:congregation_id])
    end

    if params[:since].present?
      query = query.since(params[:since])
    end

    if params[:theme].present?
      query = query.where(theme: params[:theme])
    end

    query
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def self.within_week(week = MeetingWeek.new)
    range = (week.first_day.beginning_of_day..week.last_day.end_of_day)
    where(date: range)
  end

  private

  def all_fields_required?
    !draft? && !legacy?
  end
end
