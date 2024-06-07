# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::TerritoryAssignment do
  let(:assignment) { described_class.new }

  it { expect(assignment).to belong_to(:territory) }
  it { expect(assignment).to belong_to(:assignee).class_name('Db::Publisher') }
  it { is_expected.to validate_presence_of(:assigned_at) }
  it { is_expected.not_to validate_presence_of(:returned_at) }
end
