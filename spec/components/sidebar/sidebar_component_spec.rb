# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sidebar::SidebarComponent, type: :component do
  let(:factories) { TestFactories.new }
  let(:user) { factories.users.create(enabled: true, master: false) }

  def links
    component = described_class.new
    allow(component).to receive(:current_user).and_return(user)
    render_inline(component).css('a').pluck('href')
  end

  it 'hides the integrations from people without access to them' do
    expect(links).not_to include('/finance/integrations/telegram')
  end

  it 'shows the integrations to people with access' do
    user.grant_controller_access('finance/integrations', action: 'show')

    expect(links).to include('/finance/integrations/telegram', '/finance/integrations/drive',
                             '/finance/integrations/ai')
  end
end
