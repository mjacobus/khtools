# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Db::Identifiable

  self.abstract_class = true
end
