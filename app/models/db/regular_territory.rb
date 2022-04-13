# frozen_string_literal: true

class Db::RegularTerritory < Db::Territory
  def editable_attributes
    super + %i[file file_cache]
  end
end
