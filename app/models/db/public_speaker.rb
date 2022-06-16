# frozen_string_literal: true

module Db
  class PublicSpeaker < ApplicationRecord
    belongs_to :congregation, optional: true

    scope :with_dependencies, -> { includes(:congregation) }

    validates :name, presence: true

    def congregation_name
      congregation&.name
    end
  end
end
