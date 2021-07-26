# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  belongs_to :assignee, class_name: 'Publisher', optional: true
  belongs_to :territory, class_name: 'Territory', optional: true
  belongs_to :area, class_name: 'Db::TerritoryArea', optional: true
  belongs_to :primary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :secondary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :tertiary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :intercom_type,
             class_name: 'Db::IntercomType',
             optional: true
  belongs_to :letter_box_type,
             class_name: 'Db::LetterBoxType',
             optional: true

  default_scope { order(:name) }
  scope :with_dependencies, lambda {
    includes([
      :assignee,
      :area,
      :intercom_type,
      :letter_box_type,
      :primary_preaching_method,
      :secondary_preaching_method,
      :tertiary_preaching_method,
      { territory: %i[area territory] }
    ])
  }

  identifiable_by :name

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :type }

  def area_name
    if area
      return area.name
    end

    territory&.area_name
  end

  def preaching_method_names
    [primary_preaching_method, secondary_preaching_method,
     tertiary_preaching_method].compact.map(&:name)
  end

  # rubocop:disable Metrics/MethodLength
  def self.search(params = {})
    params = SearchParams.new(params)
    arel = arel_table
    query = all

    params.if(:name) do |value|
      query = query.where(arel[:name].matches("%#{value}%"))
    end

    params.if(:publisher_id) do |value|
      query = query.where(assignee_id: value)
    end

    params.if(:phone_provider_id) do |value|
      query = query.where(phone_provider_id: value)
    end

    query
  end
  # rubocop:enable Metrics/MethodLength

  def editable_attributes
    %i[
      name
      assigned_at
      returned_at
      assignee_id
    ]
  end
end
