# frozen_string_literal: true

class Db::PublicTalk < ApplicationRecord
  belongs_to :congregation, class_name: 'Congregation', optional: true
  belongs_to :speaker, class_name: 'Db::PublicSpeaker', optional: true

  default_scope -> { order(:date) }
  scope :since, ->(date) { where('date >= ?', date) }

  validates :congregation, presence: { unless: :legacy? }
  validates :speaker, presence: { unless: :legacy? }
  validates :date, presence: true
  validates :theme, presence: true

  def theme_object
    @theme_object ||= PublicTalks::Themes.new.find(theme)
  end

  def summary
    "#{I18n.l(date.to_date)} - #{theme_object}"
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
end
