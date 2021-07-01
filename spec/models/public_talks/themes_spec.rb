# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::Themes do
  subject(:themes) { described_class.new }

  it 'lists all talks' do
    expect(themes.all.size).to eq(194)
  end

  it 'finds talk by a number' do
    theme = themes.find('36')

    expect(theme.to_s).to eq('36 - Será que a vida é só isso?')
  end
end
