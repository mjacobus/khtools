# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congregation::Publishers::PublisherPrimaryEmergencyContactComponent,
               type: :component do
  it 'renders the name and the formatted phone number' do
    publisher = factories.publishers.build(
      primary_emergency_contact_name: 'Maria',
      primary_emergency_contact_phone_number: '51999998888'
    )

    render_inline(described_class.new(publisher, attribute_name: :primary_emergency_contact))

    expect(page).to have_text('Maria - (51) 99999-8888')
  end

  it 'renders only the name when there is no phone number' do
    publisher = factories.publishers.build(primary_emergency_contact_name: 'Maria')

    render_inline(described_class.new(publisher, attribute_name: :primary_emergency_contact))

    expect(page).to have_text('Maria')
    expect(page).to have_no_text(' - ')
  end

  it 'renders nothing when there is no contact' do
    publisher = factories.publishers.build

    render_inline(described_class.new(publisher, attribute_name: :primary_emergency_contact))

    expect(page.text).to be_blank
  end
end
