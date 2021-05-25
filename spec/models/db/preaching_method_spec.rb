# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PreachingMethod, type: :model do
  subject(:method) { factories.preaching_methods.build }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
