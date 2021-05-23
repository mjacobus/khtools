# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Identifiable, type: :model do
  let(:publishers) { factories.publishers }
  let(:model) { Db::Publisher }

  it 'finds by id when there records exists' do
    publisher = publishers.create(name: 'asdfasdf')

    found = model.identify(publisher.id)

    expect(found.id).to eq publisher.id
  end

  it 'finds by name when it matches' do
    publisher = publishers.create(name: 'Judas Tadeu')

    found = model.identify('judas')

    expect(found.id).to eq publisher.id
  end

  it 'raises error when more then one name matches the findable fields' do
    publishers.create(name: 'Judas Escariotes')
    publishers.create(name: 'Judas Tadeu')

    expect { model.identify('judas') }
      .to raise_error(Db::Identifiable::AmbiguousRecordError,
                      "More than one record matches 'judas'")
  end

  it 'raises error when nothing is found' do
    expect { model.identify('judas') }
      .to raise_error(ActiveRecord::RecordNotFound,
                      "No record matches 'judas'")
  end
end
