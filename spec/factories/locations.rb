FactoryBot.define do
  factory :location, class: 'Db::Location' do
    address { 'MyText' }
    street_name { 'MyString' }
    number { '58' }
    latitude { '9.99' }
    longitude { '9.99' }
    block_number { 'MyString' }
    territory { TestFactories.new.territories.create }
    last_contacted_at { Time.zone.now }
  end
end
