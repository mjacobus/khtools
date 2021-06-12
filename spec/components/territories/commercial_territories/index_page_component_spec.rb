# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::CommercialTerritories::IndexPageComponent, type: :component do
  subject(:component) { described_class.new([]) }

  it 'has a title' do
    expect(component.title).to eq('Território Comercial')
  end
end
