# frozen_string_literal: true

module Db
  class TerritoryArea < ApplicationRecord
    has_many :territories,
             class_name: 'Territory',
             inverse_of: :area,
             foreign_key: :area_id,
             dependent: :restrict_with_exception

    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
end
