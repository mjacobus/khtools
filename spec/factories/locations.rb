FactoryBot.define do
  factory :location, class: 'Db::Location' do
    address { 'MyText' }
    street_name { 'MyString' }
    number { 'MyString' }
    latitude { '9.99' }
    longitude { '9.99' }
    block_number { 'MyString' }
    territory { nil }
    last_contacted_at { '2024-10-19 17:01:34' }
  end
end
