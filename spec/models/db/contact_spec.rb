# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Contact do
  subject(:contact) { factories.contacts.build }

  it { is_expected.to validate_presence_of(:name) }
end
