# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApartmentBuildingTerritoryCsvImportService, type: :service do
  let(:db_class) { Db::ApartmentBuildingTerritory }
  let(:imported) { db_class.last }

  # TODO: Check why I need this. Probably because of the transaction
  before do
    db_class.delete_all
    Db::TerritoryArea.delete_all
  end

  after do
    db_class.delete_all
    Db::TerritoryArea.delete_all
  end

  it 'imports csv' do
    expect { import }.to change(db_class, :count).by(1)
  end

  it 'imports name' do
    it_imports(:name)
  end

  it 'imports address' do
    it_imports(:address)
  end

  it 'imports number_of_apartments' do
    it_imports(:number_of_apartments, 10)
  end

  it 'imports primary_preaching_method' do
    it_imports(:primary_preaching_method, db_class::PREACHING_METHODS.sample)
  end

  it 'imports secondary_preaching_method' do
    it_imports(:secondary_preaching_method, db_class::PREACHING_METHODS.sample)
  end

  it 'imports tertiary_preaching_method' do
    it_imports(:tertiary_preaching_method, db_class::PREACHING_METHODS.sample)
  end

  it 'imports letter_box_type' do
    it_imports(:letter_box_type, db_class::LETTER_BOX_TYPES.sample)
  end

  it 'imports intercom_type' do
    it_imports(:intercom_type, db_class::INTERCOM_TYPES_TYPES.sample)
  end

  it 'imports has_a_roof as true' do
    it_imports(:has_a_roof, true)
  end

  it 'imports has_a_roof as false' do
    it_imports(:has_a_roof, false)
  end

  it 'imports has_a_roof as "true"' do
    it_imports(:has_a_roof, 'true', true)
  end

  it 'imports has_a_roof as "false"' do
    it_imports(:has_a_roof, 'false', false)
  end

  it 'imports apartments' do
    it_imports(:apartments)
  end

  it 'imports notes' do
    it_imports(:notes)
  end

  describe 'area' do
    context 'when area does not exist' do
      it 'creates a new area' do
        expect { import(area: 'some_area') }.to change(Db::TerritoryArea, :count).by(1)

        expect(imported.area.name).to eq('some_area')
      end
    end

    context 'when area exists' do
      it 'uses that area id' do
        area = factories.territory_areas.create

        import(area: area.name)

        expect(imported.area_id).to eq(area.id)
      end
    end
  end

  describe 'assignee' do
    context 'when user exists' do
      it 'imports assignee by name' do
        publisher = factories.publishers.create

        import(assignee: publisher.name)

        expect(imported.assignee_id).to eq(publisher.id)
      end
    end
  end

  it 'imports territory' do
    territory = factories.territories.create

    import(territory: territory.name)

    expect(imported.territory_id).to eq(territory.id)
  end

  def it_imports(field, value = nil, expected = nil)
    value = value.nil? ? "some-#{field}" : value
    expected = expected.nil? ? value : expected

    import(field => value)

    expect(imported.send(field)).to eq(expected)
  end

  def import(overrides = {})
    data = { name: 't-name', address: 'some address' }.merge(overrides)

    array = [data.keys.map(&:to_s).to_csv, data.values.to_csv]
    contents = array.join
    file = StringIO.new(contents)

    described_class.new.import_file(file)

    data
  end
end
