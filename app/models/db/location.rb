# frozen_string_literal: true

class Db::Location < ApplicationRecord
  belongs_to :territory

  scope :by_block_number, lambda {
    order(
      Arel.sql(
        "COALESCE(NULLIF(regexp_replace(block_number, '\\D+', ''), ''), '0')::int"
      )
    ) # Numeric part
      .order(Arel.sql("COALESCE(regexp_replace(block_number, '\\d+', ''), '')")) # Alphabetic part
  }

  scope :by_friendly_address, lambda {
    order(:street_name)
      .order(
        Arel.sql(
          "COALESCE(NULLIF(regexp_replace(number, '\\D+', ''), ''), '0')::int"
        )
      ) # Numeric part
      .order(Arel.sql("COALESCE(regexp_replace(number, '\\d+', ''), '')")) # Alphabetic part
  }

  validates :street_name, presence: true
  validates :number, presence: true

  def contacted_in_last_assignment?
    if last_contacted_at.nil? || territory.last_assignment.nil?
      return false
    end

    last_assignment = territory.last_assignment

    if last_assignment.returned?
      (last_assignment.assigned_at..last_assignment.returned_at).cover?(last_contacted_at)
    end

    last_contacted_at > last_assignment.assigned_at
  end

  def friendly_address
    [street_name, number.presence || '?'].join(' ')
  end

  def should_visit?
    if do_not_visit_at.present?
      return false
    end

    if contacted_in_last_assignment?
      return false
    end

    true
  end
end
