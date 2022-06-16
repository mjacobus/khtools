# frozen_string_literal: true

class SearchParams < HashWithIndifferentAccess
  def initialize(hash)
    hash.each do |key, value|
      self[key] = value if value.present?
    end
    freeze
  end

  def if(key)
    yield(self[key]) if self[key]
  end

  def any?(*keys)
    keys.flatten.find do |key|
      key?(key)
    end
  end
end
