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
    method = "territories_#{territory_type(territory)}_territories_path"
    @helpers.send(method, *args)
  end

  def territories_path(type, *args)
    method = "territories_#{type}_territories_path"
    @helpers.send(method, *args)
  end

  private

  def territory_type(territory)
    territory.class.to_s.underscore.split('/').last.sub('_territory', '')
  end
end
# rubocop:enable Style/MissingRespondToMissing
