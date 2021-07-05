# frozen_string_literal: true

class PublicTalks::Talks::IndexPageComponent < PageComponent
  attr_reader :talks

  def initialize(talks)
    @sql = talks.to_sql # for testing purposes
    @talks = talks
    setup_breadcrumb
  end

  def showing_talks_since
    if since
      t('app.messages.showing_public_talks_since', date: l(since))
    end
  end

  def new_link
    link_to(t('app.links.new'), new_public_talks_talk_path)
  end

  private

  def since
    if defined?(@since)
      return @since
    end

    @since = begin
      Date.parse(params[:since])
    rescue StandardError
      nil
    end
  end

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.public_talks'))
  end
end
