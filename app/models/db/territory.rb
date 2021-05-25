# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  belongs_to :assignee, class_name: 'Publisher', optional: true
  belongs_to :territory, class_name: 'Territory', optional: true
  belongs_to :area, class_name: 'Db::TerritoryArea', optional: true
  belongs_to :primary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :secondary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :tertiary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :intercom_type,
             class_name: 'Db::IntercomType',
             optional: true
  belongs_to :letter_box_type,
             class_name: 'Db::LetterBoxType',
             optional: true

  default_scope { order(:name) }
  identifiable_by :name

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :type }
end
