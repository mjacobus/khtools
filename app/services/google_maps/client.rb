# frozen_string_literal: true

module GoogleMaps
  class Client
    def self.create(api_key: Rails.application.secrets.dig(:google_maps, :static_api_key))
      request = Koine::RestClient::Request.new(
        base_url: 'https://maps.googleapis.com/maps/api/',
        query_params: { key: api_key }
      )
      Koine::RestClient::Client.new(base_request: request)
    end
  end
end
