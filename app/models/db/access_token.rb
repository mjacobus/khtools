# frozen_string_literal: true

class Db::AccessToken < ApplicationRecord
  validates :token, presence: true, uniqueness: { case_sensitive: false }
  validates :resource, presence: true
  validates :expires_at, presence: true

  def self.for(record)
    create!(
      resource: resource_as_string(record),
      token: UniqueId.new,
      expires_at: 24.hours.from_now
    )
  end

  def valid_for?(record)
    !expired? && self.class.send(:resource_as_string, record) == resource
  end

  def expired?
    Time.now.utc > expires_at.utc
  end

  class << self
    private

    def resource_as_string(record)
      "#{record.class}:#{record.id}"
    end
  end
end
