# frozen_string_literal: true

module Territories
  class AssignmentComponent < ApplicationComponent
    has :assignment
    has :parent

    def territory_perspective?
      parent.is_a?(Db::Territory)
    end

    def publisher_perspective?
      parent.is_a?(Db::Publisher)
    end
  end
end
