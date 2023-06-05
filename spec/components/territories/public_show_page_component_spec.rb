# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::PublicShowPageComponent, type: :component do
  subject(:component) { described_class.new(territory: territory) }

  let(:territory) { factories.territories.build }

  it 'renders something useful' do
    render_inline(component)

    expect(page).to have_text(territory.name)
  end
end
