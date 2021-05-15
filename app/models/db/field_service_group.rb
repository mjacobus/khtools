# frozen_string_literal: true

class Db::FieldServiceGroup < ApplicationRecord
  has_many :publishers,
           foreign_key: :group_id,
           inverse_of: :group,
           dependent: :restrict_with_exception
end