# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Db::Territory < ApplicationRecord
  AssignmentError = Class.new(StandardError)

  UNASSIGNED_TERRITORY_VALUE = 'none'

  belongs_to :account, class_name: 'Db::Account'
  belongs_to :assignee, class_name: 'Publisher', optional: true
  belongs_to :field_service_group, class_name: 'FieldServiceGroup', optional: true
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
  has_many :assignments, class_name: 'Db::TerritoryAssignment', dependent: :restrict_with_exception

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
  scope :with_account, ->(account) { where(account: account) }
  scope :regular, -> { where(type: 'Db::RegularTerritory') }

  identifiable_by :name

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, scope: %i[account_id type] }

  mount_uploader :file, if Rails.env.production?
                          Territories::Uploaders::CloudinaryUploader
                        else
                          Territories::Uploaders::LocalUploader
                        end

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

    params.if(:field_service_group_id) do |value|
      query = query.where(field_service_group_id: value)
    end

    params.if(:area_id) do |value|
      query = query.where(area_id: value)
    end

    params.if(:territory_id) do |value|
      query = query.where(territory_id: value)
    end

    params.if(:pending_verification) do |value|
      query = query.where(pending_verification: value)
    end

    params.if(:preaching_method_id) do |value|
      query = query.where(primary_preaching_method_id: value)
        .or(query.where(secondary_preaching_method_id: value))
        .or(query.where(tertiary_preaching_method_id: value))
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
      google_map
      assigned_at
      assignee_id
      field_service_group_id
    ]
  end

  def type_key
    @type_key ||= self.class.to_s.underscore.split('/').last.sub('_territory', '')
  end

  # rubocop:disable Metrics/MethodLength
  def assign_to(publisher, campaign_id: nil, notes: nil)
    if assigned?
      raise AssignmentError, 'Already assigned'
    end

    if publisher.is_a?(Db::Publisher)
      publisher = publisher.id
    end

    self.assignee_id = publisher
    self.assigned_at = Time.zone.now

    self.class.transaction do
      save!
      assignments.create!(
        assignee_id: assignee_id,
        assigned_at: assigned_at,
        campaign_id: campaign_id,
        notes: notes
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def return
    assignments_to_return = assignments.where(assignee_id: assignee_id)

    self.assignee_id = nil
    self.assigned_at = nil

    self.class.transaction do
      assignments_to_return.map(&:return)
      save!
    end
  end

  def assigned?
    assignee_id.present?
  end
end
# rubocop:enable Metrics/ClassLength
