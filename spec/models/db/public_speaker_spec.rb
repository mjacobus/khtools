# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PublicSpeaker, type: :model do
  subject(:speaker) { factories.public_speakers.build }

  it { is_expected.to validate_presence_of(:name) }
end
