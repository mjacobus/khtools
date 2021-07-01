# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::Theme do
  let(:theme) { described_class.new(36) }

  it 'has a theme' do
    expect(theme.theme).to eq('Será que a vida é só isso?')
  end

  it 'converts to string' do
    expect(theme.to_s).to eq('36 - Será que a vida é só isso?')
  end
end
