# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PreachingMethod do
  subject(:method) { factories.preaching_methods.build }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it 'has many primary_territories' do
    expect(method).to have_many(:primary_territories)
      .class_name('Db::Territory')
      .inverse_of(:primary_preaching_method)
      .dependent(:restrict_with_exception)
  end

  it 'has many secondary_territories' do
    expect(method).to have_many(:secondary_territories)
      .class_name('Db::Territory')
      .inverse_of(:secondary_preaching_method)
      .dependent(:restrict_with_exception)
  end

  it 'has many tertiary_territories' do
    expect(method).to have_many(:tertiary_territories)
      .class_name('Db::Territory')
      .inverse_of(:tertiary_preaching_method)
      .dependent(:restrict_with_exception)
  end
end
