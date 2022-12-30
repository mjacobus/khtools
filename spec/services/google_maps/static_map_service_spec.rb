# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleMaps::StaticMapService do
  subject(:service) { described_class.new(api_key: 'the-key') }

  let(:kml) do
    read_fixture(
      [
        'maps/multi-layer.kml',
        'maps/single-layer.kml'
      ].sample
    )
  end

  describe '#url_from_kml' do
    let(:url) { service.url_from_kml(kml) }
    let(:parsed) { Addressable::URI.parse(url.to_s) }

    it 'sets the boundaries' do
      expected = 'color:0x0000ff|weight:5|10.0,20.0|30.0,40.0|10.0,20.0'
      expect(url.query_params['path']).to eq(expected)
    end

    it 'sets the center' do
      allow_any_instance_of(GoogleMaps::Kml::Nodes::Coordinates) # rubocop:disable RSpec/AnyInstance
        .to receive(:center)
        .and_return(%w[x y])

      expected = 'x,y'

      expect(url.query_params['center']).to eq(expected)
    end
  end
end
