require 'rails_helper'

RSpec.describe Publisher, type: :model do
  it 'persists' do
    Publisher.create!(name: 'John Doe')

    expect(Publisher.count).to be 1
  end
end
