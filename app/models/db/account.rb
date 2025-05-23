# frozen_string_literal: true

class Db::Account < ApplicationRecord
  encrypts :secrets

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

  def cloudinary_cloud_name=(value)
    write_secret(:cloudinary_cloud_name, value)
  end

  def cloudinary_cloud_name
    read_secret(:cloudinary_cloud_name)
  end

  def cloudinary_api_key=(value)
    write_secret(:cloudinary_api_key, value)
  end

  def cloudinary_api_key
    read_secret(:cloudinary_api_key)
  end

  def cloudinary_api_secret=(value)
    write_secret(:cloudinary_api_secret, value)
  end

  def cloudinary_api_secret
    read_secret(:cloudinary_api_secret)
  end

  def google_api_key_for_static_maps=(value)
    write_secret(:google_api_key_for_static_maps, value)
  end

  def google_api_key_for_static_maps
    read_secret(:google_api_key_for_static_maps)
  end

  def supports_uploads?
    [cloudinary_cloud_name, cloudinary_api_key, cloudinary_api_secret].all?(&:present?)
  end

  private

  def write_secret(attribute, value)
    parsed_secrets[attribute.to_s] = value
    self.secrets = parsed_secrets.to_json
  end

  def read_secret(attribute)
    parsed_secrets[attribute.to_s]
  end

  def parsed_secrets
    @parsed_secrets ||= if secrets.is_a?(String)
                          JSON.parse(secrets)
                        else
                          {}
                        end
  end
end
