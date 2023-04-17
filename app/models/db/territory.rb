# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Db::Territory < ApplicationRecord
  include TerritoryUploaderConcern

  UNASSIGNED_TERRITORY_VALUE = 'none'

  belongs_to :account, class_name: 'Db::Account'
  belongs_to :assignee, class_name: 'Publisher', optional: true
  belongs_to :field_service_group, class_name: 'FieldServiceGroup', optional: true
  belongs_to :territory, class_name: 'Territory', optional: true
  belongs_to :area, class_name: 'Db::TerritoryArea', optional: true
  belongs_to :primary_preaching_method,
             class_name: 'Db::PreachingMethod',
             optional: true
  belongs_to :last_assignment,
             class_name: 'Db::TerritoryAssignment',
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
      :field_service_group,
      :last_assignment,
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

  mount_uploader :file, file_uploader

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

  def editable_attributes # rubocop:disable Metrics/MethodLength
    %i[
      notes
      pending_verification
      name
      google_map
      kml
      assigned_at
      assignee_id
      field_service_group_id
      static_map_zoom
      static_map_scale
      static_map_size
      static_map_center
    ]
  end

  def type_key
    @type_key ||= self.class.to_s.underscore.split('/').last.sub('_territory', '')
  end

  def assign_to(publisher, campaign: nil, notes: nil)
    TerritoryAssignmentService.new.assign(
      territory: self,
      to: publisher,
      campaign: campaign,
      notes: notes
    )
  end

  def return
    TerritoryAssignmentService.new.return_territory(territory: self)
  end

  def static_map_url(params = {})
    if has_static_map?
      params = { size: '2048x2048', zoom: 17, scale: 4 }

      GoogleMaps::StaticMapService
        .new(api_key: account.google_api_key_for_static_maps)
        .url_from_kml(kml)
        .with_added_query_params(params.merge(custom_map_params).merge(params))
    end
  end

  def has_static_map?
    kml.present? && account.google_api_key_for_static_maps.present?
  end

  def assigned?
    assignee_id.present?
  end

  def google_api_key_for_static_maps
    read_secret(:google_api_key_for_static_maps)
  end

  def supports_uploads?
    [cloudinary_cloud_name, cloudinary_api_key, cloudinary_api_secret].all?(&:present?)
  end

  def static_map_zoom=(value)
    write_config(:static_map_zoom, value)
  end

  def static_map_zoom
    read_config(:static_map_zoom)
  end

  def static_map_scale=(value)
    write_config(:static_map_scale, value)
  end

  def static_map_scale
    read_config(:static_map_scale)
  end

  def static_map_size=(value)
    write_config(:static_map_size, value)
  end

  def static_map_size
    read_config(:static_map_size)
  end

  def static_map_center=(value)
    write_config(:static_map_center, value)
  end

  def static_map_center
    read_config(:static_map_center)
  end

  def filename(extension = nil)
    [name, extension].compact.join('.')
  end

  private

  def write_config(attribute, value)
    parsed_config[attribute.to_s] = value
  end

  def read_config(attribute)
    parsed_config[attribute.to_s]
  end

  def parsed_config
    self.config ||= {}
  end

  def custom_map_params
    {
      zoom: static_map_zoom,
      scale: static_map_scale,
      size: static_map_size,
      center: static_map_center
    }.compact_blank
  end
end
# rubocop:enable Metrics/ClassLength
