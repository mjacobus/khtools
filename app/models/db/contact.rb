# frozen_string_literal: true

module Db
  class Contact < ApplicationRecord
    validates :name, presence: true
  end
end
