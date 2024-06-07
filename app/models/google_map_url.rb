# frozen_string_literal: true

require 'koine/url'

class GoogleMapUrl
  def initialize(url)
    @value = url.to_s
  end

  def to_s
    @value
  end

  def embeddable
    new(@value.sub('/edit?', '/embed?'))
  end

  def editable
    new(@value.sub('/embed?', '/edit?'))
  end

  def with_background(color)
    color = color.sub('#', '')
    url = Koine::Url.new(@value).with_query_param(:ehbc, color)
    new(url)
  end

  private

  def new(value)
    self.class.new(value)
  end
end
