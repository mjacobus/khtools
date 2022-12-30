# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleMaps::Kml::Nodes::Coordinates do
  subject(:node) { described_class.new(xml_node) }

  let(:xml_node) { double(text: text) }

  describe '#center' do
    let(:text) do
      <<-TEXT

          -3,17,0
          -20,31,0

      TEXT
    end

    it 'returns the middle point' do
      expect(node.center).to eq([8.5, 7.0])
    end
  end
end
