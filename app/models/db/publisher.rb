# frozen_string_literal: true

class Db::Publisher < ApplicationRecord
  default_scope { order(:name) }
  belongs_to :group, class_name: 'FieldServiceGroup'

  has_many :territories,
           foreign_key: :assignee_id,
           inverse_of: :assignee,
           dependent: :restrict_with_exception

  validates :name, presence: true
  validates :gender, presence: true

  def self.identify(term)
    find_by(name: term)
  end
end
