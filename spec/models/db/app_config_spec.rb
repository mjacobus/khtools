# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::AppConfig, type: :model do
  it { is_expected.to validate_uniqueness_of(:key).case_insensitive }
  it { is_expected.to validate_presence_of(:value) }
end
