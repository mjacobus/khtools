# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  let(:current_user) { admin_user }
  let(:user) { factories.users.create(name: 'Bia Lima', account: current_account, enabled: false) }
  let(:publisher) { factories.publishers.create(account: current_account, name: 'Beatriz Lima') }

  def page
    Nokogiri::HTML(response.body)
  end

  def update(**fields)
    patch "/users/#{user.id}", params: { user: { controller_accesses: [''], **fields } }
  end

  it 'lists the users with their congregation and publisher, linking to edit them' do
    publisher.update!(user:)

    get '/users'

    row = page.at("tr#user-#{user.id}")
    expect(row.text.squish)
      .to include('Bia Lima', current_account.congregation_name, 'Beatriz Lima')
    expect(row.at("a[href='/users/#{user.id}/edit']")).to be_present
  end

  it "offers the publishers of the user's congregation" do
    publisher
    factories.publishers.create(name: 'De outra congregação')

    get "/users/#{user.id}/edit"

    expect(page.css('select[name="user[publisher_id]"] option').map(&:text))
      .to eq(['Nenhum', 'Beatriz Lima'])
  end

  it 'saves access, admin, congregation and screens' do
    update(enabled: '1', master: '1', controller_accesses: ['', 'finance/documents#index'])

    expect(user.reload).to have_attributes(enabled: true, master: true,
                                           controller_accesses: ['finance/documents#index'])
    expect(response).to redirect_to('/users')
  end

  it 'links the publisher, unlinking the one before' do
    before = factories.publishers.create(account: current_account, user:)

    update(publisher_id: publisher.id)

    expect(user.reload.publisher).to eq(publisher)
    expect(before.reload.user).to be_nil
  end

  it 'unlinks the publisher' do
    publisher.update!(user:)

    update(publisher_id: '')

    expect(publisher.reload.user).to be_nil
  end

  context 'when not an admin' do
    let(:current_user) { regular_user }

    it 'sends them home' do
      update(master: '1')

      expect(response).to redirect_to('/')
      expect(user.reload.master).to be(false)
    end
  end
end
