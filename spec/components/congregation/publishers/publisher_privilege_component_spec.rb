# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congregation::Publishers::PublisherPrivilegeComponent, type: :component do
  it 'renders the privileges held' do
    publisher = factories.publishers.build(elder: true, pioneer: true)

    render_inline(described_class.new(publisher, attribute_name: :privileges))

    expect(page).to have_text('Ancião, Pioneiro')
  end

  it 'renders nothing when the publisher has no privileges' do
    publisher = factories.publishers.build

    render_inline(described_class.new(publisher, attribute_name: :privileges))

    expect(page.text).to be_blank
  end
end
