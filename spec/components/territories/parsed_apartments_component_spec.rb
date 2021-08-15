# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::ParsedApartmentsComponent, type: :component do
  describe '#grouped_apartments' do
    it 'gruops by floor' do
      apartments = ['801', '802', '901', '902', '1001', '1002', '1101', '1102']
      component = described_class.new(apartments: apartments)
      
      grouped = []

      component.grouped_apartments.each do |_, group|
        grouped << group
      end

      expect(grouped).to eq([
        ['801', '802'],
        ['901', '902'],
        ['1001', '1002'],
        ['1101', '1102'],
      ])
    end
  end
end
