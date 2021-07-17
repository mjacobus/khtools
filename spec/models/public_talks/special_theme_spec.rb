# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::SpecialTheme do
  let(:theme) { described_class.new('Some theme') }

  it 'has a theme' do
    expect(theme.theme).to eq('Some theme')
  end

  it 'converts to string' do
    expect(theme.to_s).to eq('Some theme')
  end
end
