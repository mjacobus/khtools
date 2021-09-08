# frozen_string_literal: true

require 'addressable/template'

module GoogleMapsHelper
  def google_maps
    @google_maps ||= GoogleMapsHelperObject.new
  end

  class GoogleMapsHelperObject
    URL = 'https://maps.googleapis.com/maps/api/js'
    KEY = 'AIzaSyCMFbHjf-I2rApFaatnmukLyfb1VIB8Jhk'

    def js_source(params = {})
      url = Addressable::Template.new("#{URL}{?query*}")
      url.expand(query: { key: KEY }.merge(params)).to_s
    end
  end
end
