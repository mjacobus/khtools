# frozen_string_literal: true

module Territories
  class AssignmentsComponent < ApplicationComponent
    has :record

    def render?
      record.assignments.any?
    end
  end
end
