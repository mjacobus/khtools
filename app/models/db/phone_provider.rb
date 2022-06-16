# frozen_string_literal: true

module Db
  class PhoneProvider < ApplicationRecord
    default_scope { order(:name) }

    has_many :phone_list_territories,
             dependent: :restrict_with_exception

    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
end
