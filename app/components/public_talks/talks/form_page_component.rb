# frozen_string_literal: true

class PublicTalks::Talks::FormPageComponent < PageComponent
  attr_reader :talk

  def initialize(talk)
    @talk = talk
    breadcrumb.add_item(t('app.links.public_talks'), urls.public_talks_talks_path)

    if talk.id
      breadcrumb.add_item(
        talk.date,
        urls.public_talks_talk_path(talk)
      )
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end

  def target_url
    if talk.id
      return public_talks_talk_path(talk)
    end

    public_talks_talks_path
  end

  def collection_for_congregation
    Db::Congregation.order(:name).pluck(:name, :id)
  end

  def collection_for_speaker
    query = Db::PublicSpeaker.order(:name).includes(:congregation)
    query.pluck(:id, :name, 'congregations.name').map do |fields|
      ["#{fields[1]} (#{fields[2]})", fields[0]]
    end
  end

  def collection_for_theme
    1.upto(200).map { |n| [n, n] }
  end
end
