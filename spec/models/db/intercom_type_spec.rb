# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::IntercomType do
  subject(:type) { factories.intercom_types.build }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it 'has many territories' do
    expect(type).to have_many(:territories)
      .class_name('Db::Territory')
      .inverse_of(:intercom_type)
      .dependent(:restrict_with_exception)
  end
end
