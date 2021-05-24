# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::IntercomType, type: :model do
  subject(:type) { factories.intercom_types.build }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
