# frozen_string_literal: true

class Db::ApartmentBuildingTerritory < Db::Territory
  PREACHING_METHODS = %w[
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

  belongs_to :area, class_name: 'Db::TerritoryArea', optional: true
  validates :address, presence: true
  # validates :number_of_apartments, presence: true
  validates :primary_preaching_method,
            inclusion: { in: PREACHING_METHODS },
            allow_nil: true
  validates :secondary_preaching_method,
            inclusion: { in: PREACHING_METHODS },
            allow_nil: true
  validates :tertiary_preaching_method,
            inclusion: { in: PREACHING_METHODS },
            allow_nil: true
  validates :letter_box_type,
            inclusion: { in: LETTER_BOX_TYPES },
            allow_nil: true
  validates :intercom_type,
            inclusion: { in: INTERCOM_TYPES_TYPES },
            allow_nil: true
end
