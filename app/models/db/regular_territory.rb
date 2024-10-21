# frozen_string_literal: true

class Db::RegularTerritory < Db::Territory
  has_many :locations,
           dependent: :destroy,
           class_name: 'Db::Location',
           foreign_key: :territory_id,
           inverse_of: :territory

  def editable_attributes
    super + %i[file file_cache]
  end
end
