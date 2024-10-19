require 'rails_helper'

RSpec.describe Db::Location, type: :model do
  let(:location) { FactoryBot.create(:location) }

  it "has a valid factory" do
    expect(location).to be_valid
  end

  it "belongs to territory" do
    expect(location).to belong_to(:territory)
  end
end
