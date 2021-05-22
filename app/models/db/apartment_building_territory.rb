# frozen_string_literal: true

class Db::ApartmentBuildingTerritory < Db::Territory
  PRECHING_METHODS = %w[
    itermcom
    letters
  ].freeze

  LETTER_BOX_TYPES = %w[
    individual
    intern
    unique
    inexistent
  ].freeze

  INTERCOM_TYPES_TYPES = %w[
    individual
    intern
    unique
    inexistent
  ].freeze

  belongs_to :area, class_name: 'Db::TerritoryArea'
  validates :address, presence: true
  validates :number_of_apartments, presence: true
  validates :primary_preaching_method, inclusion: { in: PRECHING_METHODS }
  validates :secondary_preaching_method, inclusion: { in: PRECHING_METHODS }
  validates :tertiary_preaching_method, inclusion: { in: PRECHING_METHODS }
  validates :letter_box_type, inclusion: { in: LETTER_BOX_TYPES }
  validates :intercom_type, inclusion: { in: INTERCOM_TYPES_TYPES }
end
