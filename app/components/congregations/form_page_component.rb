# frozen_string_literal: true

class Congregations::FormPageComponent < PageComponent
  attr_reader :congregation

  def initialize(congregation)
    @congregation = congregation
  end

  def target_url
    if congregation.id
      return public_talks_congregation_path(congregation)
    end

    public_talks_congregations_path
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.congregations'), urls.public_talks_congregations_path)

    if congregation.id
      breadcrumb.add_item(
        congregation.name,
        urls.public_talks_congregation_path(congregation)
      )
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end
end
