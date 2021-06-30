# frozen_string_literal: true

class Congregations::FormPageComponent < PageComponent
  attr_reader :congregation

  def initialize(congregation)
    @congregation = congregation
    breadcrumb.add_item(t('app.links.congregations'), urls.public_talks_congregations_path)
  end

  def target_url
    if congregation.id
      return public_talks_congregation_path(congregation)
    end

    public_talks_congregations_path
  end
end
