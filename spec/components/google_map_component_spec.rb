# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleMapComponent, type: :component do
  subject(:component) { described_class.new(**args) }

  let(:args) { { url: 'https://www.google.com/maps/d/u/0/edit?mid=xyz&usp=sharing' } }

  it 'renders' do
    render_inline component

    url = GoogleMapUrl.new(args[:url]).embeddable.with_background('395c96')

    expect(page).to have_css("iframe[src='#{url}']")
  end

  it 'renders nothing if url is not present' do
    args[:url] = ''

    render_inline component

    expect(page).to have_no_css('iframe')
  end
end
