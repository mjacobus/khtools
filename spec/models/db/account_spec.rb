# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Account, type: :model do
  it { is_expected.to validate_uniqueness_of(:congregation_name).case_insensitive }
  it { is_expected.to have_many(:users) }
end
