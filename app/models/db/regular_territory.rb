# frozen_string_literal: true

module Db
  class RegularTerritory < Db::Territory
    def editable_attributes
      super + %i[file file_cache]
    end
  end
end
