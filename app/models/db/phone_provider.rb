# frozen_string_literal: true

class Db::PhoneProvider < ApplicationRecord
  default_scope { order(:name) }

  has_many :phone_list_territories,
           dependent: :restrict_with_exception
end
