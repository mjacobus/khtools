# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congregation::Publishers::PublisherSecondaryEmergencyContactComponent,
               type: :component do
  it 'renders the secondary contact' do
    publisher = factories.publishers.build(
      secondary_emergency_contact_name: 'João',
      secondary_emergency_contact_phone_number: '51977776666'
    )

    render_inline(described_class.new(publisher, attribute_name: :secondary_emergency_contact))

    expect(page).to have_text('João - (51) 97777-6666')
  end
end
