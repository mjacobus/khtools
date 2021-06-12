# frozen_string_literal: true

# rubocop:disable Rails/HasAndBelongsToMany
class Db::CommercialTerritory < Db::Territory
  has_and_belongs_to_many :contacts,
                          foreign_key: 'territory_id',
                          class_name: 'Db::Contact',
                          dependent: :restrict_with_exception
end
# rubocop:enable Rails/HasAndBelongsToMany
