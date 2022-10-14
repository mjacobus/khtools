# frozen_string_literal: true

class Db::FieldServiceGroup < ApplicationRecord
  has_many :publishers,
           foreign_key: :group_id,
           inverse_of: :group,
           dependent: :restrict_with_exception

  belongs_to :account, class_name: 'Db::Account'

  scope :active, -> { where("name NOT LIKE '\\_%'") }
  scope :with_dependencies, -> { includes([:publishers]) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:account_id] }
end
