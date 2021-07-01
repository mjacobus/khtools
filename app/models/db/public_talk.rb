# frozen_string_literal: true

class Db::PublicTalk < ApplicationRecord
  belongs_to :congregation, class_name: 'Congregation', optional: true
  belongs_to :speaker, class_name: 'Db::PublicSpeaker', optional: true

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
end
