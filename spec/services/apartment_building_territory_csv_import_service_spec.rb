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

  it 'imports building_name' do
    it_imports(:building_name)
  end

  it 'imports address' do
    it_imports(:address)
  end

  it 'imports number_of_apartments' do
    it_imports(:number_of_apartments, 10)
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

  describe 'letter_box_type' do
    context 'when it exists' do
      it 'assigns it' do
        type = factories.letter_box_types.create

        import(letter_box_type: type.name)

        expect(imported.letter_box_type.id).to eq(type.id)
      end
    end

    context 'when it does not exists' do
      it 'assigns it' do
        import(letter_box_type: 'some name')

        expect(imported.letter_box_type.name).to eq('some name')
      end
    end
  end

  describe 'intercom_type' do
    context 'when it exists' do
      it 'assigns it' do
        type = factories.intercom_types.create

        import(intercom_type: type.name)

        expect(imported.intercom_type.id).to eq(type.id)
      end
    end

    context 'when it does not exists' do
      it 'assigns it' do
        import(intercom_type: 'some name')

        expect(imported.intercom_type.name).to eq('some name')
      end
    end
  end

  describe 'primary_preaching_method' do
    context 'when it exists' do
      it 'assigns it' do
        method = factories.preaching_methods.create

        import(primary_preaching_method: method.name)

        expect(imported.primary_preaching_method.id).to eq(method.id)
      end
    end

    context 'when it does not exists' do
      it 'assigns it' do
        import(primary_preaching_method: 'some name')

        expect(imported.primary_preaching_method.name).to eq('some name')
      end
    end
  end

  describe 'secondary_preaching_method' do
    context 'when it exists' do
      it 'assigns it' do
        method = factories.preaching_methods.create

        import(secondary_preaching_method: method.name)

        expect(imported.secondary_preaching_method.id).to eq(method.id)
      end
    end

    context 'when it does not exists' do
      it 'assigns it' do
        import(secondary_preaching_method: 'some name')

        expect(imported.secondary_preaching_method.name).to eq('some name')
      end
    end
  end

  describe 'tertiary_preaching_method' do
    context 'when it exists' do
      it 'assigns it' do
        method = factories.preaching_methods.create

        import(tertiary_preaching_method: method.name)

        expect(imported.tertiary_preaching_method.id).to eq(method.id)
      end
    end

    context 'when it does not exists' do
      it 'assigns it' do
        import(tertiary_preaching_method: 'some name')

        expect(imported.tertiary_preaching_method.name).to eq('some name')
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
    expected = value if expected.nil?

    import(field => value)

    expect(imported.send(field)).to eq(expected)
  end

  def import(overrides = {})
    data = { name: 't-name', address: 'some address', something_else: 'nope' }.merge(overrides)

    array = [data.keys.map(&:to_s).to_csv, data.values.to_csv]
    contents = array.join
    file = StringIO.new(contents)

    described_class.new.import_file(file)

    data
  end
end
