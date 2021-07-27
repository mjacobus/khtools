# frozen_string_literal: true

# rubocop:disable Style/MissingRespondToMissing
class Routes
  def initialize(helpers = Rails.application.routes.url_helpers)
    @helpers = helpers
  end

  def method_missing(*args)
    @helpers.send(*args)
  end

  def territory_path(territory, *args)
    method = "territories_#{territory.type_key}_territory_path"
    @helpers.send(method, territory, *args)
  end

  def territories_path(type, *args)
    method = "territories_#{type}_territories_path"
    @helpers.send(method, *args)
  end
end
# rubocop:enable Style/MissingRespondToMissing
