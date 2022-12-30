# frozen_string_literal: true

class Db::Account < ApplicationRecord
  # rails 7 apparently
  # encrypts :secrets

  validates :congregation_name, uniqueness: { case_sensitive: false }, presence: true

  has_many :users, dependent: :restrict_with_exception
  has_many :publishers, dependent: :restrict_with_exception, class_name: 'Db::Publisher'
  has_many :field_service_groups, dependent: :restrict_with_exception,
                                  class_name: 'Db::FieldServiceGroup'
  has_many :territories, dependent: :restrict_with_exception,
                         class_name: 'Db::Territory'
  has_many :preaching_campaigns, dependent: :restrict_with_exception,
                                 class_name: 'Db::PreachingCampaign'

  def to_s
    congregation_name
  end
end
