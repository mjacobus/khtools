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

  it 'shows the account documents only to people with access to them' do
    expect(links).not_to include('/finance/documents')

    user.grant_controller_access('finance/documents', action: 'index')

    expect(links).to include('/finance/documents')
  end

  it 'lists the documents under Contas' do
    user.grant_controller_access('finance/documents', action: 'index')

    component = described_class.new
    allow(component).to receive(:current_user).and_return(user)
    page = render_inline(component)

    expect(page.at('a[href="/finance/documents"]').text.strip).to eq('Documentos')
    expect(page.text).to include('Contas')
  end
end
