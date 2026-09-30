# frozen_string_literal: true

class Db::Publisher < ApplicationRecord
  default_scope { order(:name) }
  identifiable_by :name

  belongs_to :group, class_name: 'FieldServiceGroup'
  belongs_to :account, class_name: 'Db::Account'
  belongs_to :user, optional: true

  has_many :territories,
           foreign_key: :assignee_id,
           inverse_of: :assignee,
           dependent: :restrict_with_exception

  has_many :assignments,
           foreign_key: :assignee_id,
           class_name: 'Db::TerritoryAssignment',
           inverse_of: :assignee,
           dependent: :restrict_with_exception

  validates :name, presence: true
  validates :gender, presence: true
  validates :user, uniqueness: true, allow_nil: true
  validate :group_belongs_to_account
  validate :user_belongs_to_account
  validate :appointed_privileges

  PRIVILEGES = %i[elder ministerial_servant pioneer].freeze

  def to_s
    name
  end

  def privileges
    PRIVILEGES.select { |privilege| send(privilege) }
  end

  private

  def group_belongs_to_account
    if group && group.account_id != account_id
      errors.add(:group, :invalid)
    end
  end

  def user_belongs_to_account
    if user && user.account_id != account_id
      errors.add(:user, :invalid)
    end
  end

  def appointed_privileges
    if gender != 'm'
      %i[elder ministerial_servant].select { |privilege| send(privilege) }.each do |privilege|
        errors.add(privilege, :invalid)
      end
      return
    end

    if elder && ministerial_servant
      errors.add(:ministerial_servant, :invalid)
    end
  end
end
