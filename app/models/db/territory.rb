# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  UNASSIGNED_TERRITORY_VALUE = 'none'

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
  # rubocop:disable Metrics/AbcSize
  def self.search(params = {})
    params = SearchParams.new(params)
    arel = arel_table
    query = all

    params.if(:name) do |value|
      query = query.where(arel[:name].matches("%#{value}%"))
    end

    params.if(:publisher_id) do |value|
      query = if value == UNASSIGNED_TERRITORY_VALUE
                query.where(assignee_id: nil)
              else
                query.where(assignee_id: value)
              end
    end

    params.if(:phone_provider_id) do |value|
      query = query.where(phone_provider_id: value)
    end

    params.if(:area_id) do |value|
      query = query.where(area_id: value)
    end

    query
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def editable_attributes
    %i[
      notes
      pending_verification
      name
      assigned_at
      returned_at
      assignee_id
    ]
  end

  def type_key
    @type_key ||= self.class.to_s.underscore.split('/').last.sub('_territory', '')
  end

  def assign_to(publisher)
    unless publisher.is_a?(Db::Publisher)
      publisher = Db::Publisher.find(publisher)
    end

    self.assignee_id = publisher.id
    self.assigned_at = Time.zone.now
    self.returned_at = nil
    save!
  end

  def return
    self.assignee_id = nil
    self.assigned_at = nil
    self.returned_at = nil
    save!
  end

  def assigned?
    assignee_id.present?
  end
end
