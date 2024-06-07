# frozen_string_literal: true

# rubocop:disable Style/MissingRespondToMissing
class Routes
  def initialize(helpers = Rails.application.routes.url_helpers)
    @helpers = helpers
  end

  def method_missing(*)
    @helpers.send(*)
  end

  def territory_path(territory, *)
    method = "territories_#{territory.type_key}_territory_path"
    @helpers.send(method, territory, *)
  end

  def public_territory_url(territory)
    base = territory_path(territory)
    "#{root_url}/#{base}/token/#{territory.public_view_token}"
  end

  def territories_path(type, *)
    method = "territories_#{type}_territories_path"
    @helpers.send(method, *)
  end

  def territory_tokenized_files_path(territory)
    @helpers.create_token_territories_phone_list_territory_path(territory)
  end

  def territory_download_xls_path(territory, params = {})
    @helpers.xls_territories_phone_list_territory_path(territory, params)
  end

  def territory_download_pdf_path(territory, params = {})
    @helpers.pdf_territories_phone_list_territory_path(territory, params)
  end

  def territory_download_printable_path(territory, params = {})
    @helpers.territories_regular_territory_printable_path(territory, params)
  end

  def new_territory_assignment_path(territory)
    @helpers.new_territories_territory_assignment_path(territory)
  end

  def territory_assignments_path(territory)
    path = territory_path(territory)
    "#{path}/assignments"
  end

  def territory_assignment_path(assignment)
    path = territory_assignments_path(assignment.territory)
    "#{path}/#{assignment.to_param}"
  end

  def edit_territory_assignment_path(assignment)
    path = territory_assignment_path(assignment)
    "#{path}/edit"
  end

  def return_territory_path(territory)
    @helpers.territories_territory_assignment_path(territory, 'unassign')
  end

  def preaching_campaigns_path(args = {})
    @helpers.field_service_campaigns_path(args)
  end

  def preaching_campaign_path(campaign)
    @helpers.field_service_campaign_path(campaign)
  end

  def new_field_service_campaign_path
    @helpers.new_field_service_campaign_path
  end

  def publishers_path(*)
    @helpers.congregation_publishers_path(*)
  end

  def publisher_path(*)
    @helpers.congregation_publisher_path(*)
  end

  def new_publisher_path
    "#{publishers_path}/new"
  end

  def edit_publisher_path(publisher)
    "#{to(publisher)}/edit"
  end

  def to(record)
    key = record.class.to_s.underscore.split('/').last

    candidate = "#{key}_path"

    if respond_to?(candidate)
      return send(candidate, record)
    end

    if record.is_a?(Db::Territory)
      return territory_path(record)
    end

    raise "Unrecognized path for #{record.class}/#{key}"
  end

  def root_url
    Current.root_url
  end
end
# rubocop:enable Style/MissingRespondToMissing
