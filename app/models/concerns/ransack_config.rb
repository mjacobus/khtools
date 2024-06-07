# frozen_string_literal: true

module RansackConfig
  extend ActiveSupport::Concern

  # We need this now because there is a whitelist for attributes to be searched by Ransack
  # We don't use ransack directly, but active admin depends on it
  module ClassMethods
    # Allow all attributes to be searchable
    def ransackable_attributes(_auth_object = nil)
      column_names
    end

    # Allow all associations to be searchable
    def ransackable_associations(_auth_object = nil)
      reflect_on_all_associations.map { |a| a.name.to_s }
    end
  end
end
