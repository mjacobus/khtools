# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Db::Identifiable
  include RansackConfig

  self.abstract_class = true

  def self.coerce(value, allow_nil: true)
    if allow_nil && value.presence.nil?
      return nil
    end

    if value.is_a?(self)
      return value
    end

    find(value)
  end

  def self.to_id(record_or_id)
    if record_or_id.is_a?(self)
      return record_or_id.id
    end

    record_or_id
  end
end
