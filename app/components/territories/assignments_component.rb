# frozen_string_literal: true

module Territories
  class AssignmentsComponent < ApplicationComponent
    has :record

    def assignments
      record.assignments.with_dependencies
    end

    def render?
      record.assignments.any?
    end
  end
end
