# frozen_string_literal: true

class Db::PreachingMethod < ApplicationRecord
  has_many :primary_territories,
           class_name: 'Territory',
           foreign_key: :primary_preaching_method_id,
           inverse_of: :primary_preaching_method,
           dependent: :restrict_with_exception

  has_many :secondary_territories,
           class_name: 'Territory',
           foreign_key: :secondary_preaching_method_id,
           inverse_of: :secondary_preaching_method,
           dependent: :restrict_with_exception

  has_many :tertiary_territories,
           class_name: 'Territory',
           foreign_key: :tertiary_preaching_method_id,
           inverse_of: :tertiary_preaching_method,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
