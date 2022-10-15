# frozen_string_literal: true

class GoogleMapComponent < ApplicationComponent
  def initialize(url:, width: 640, height: 480, color: nil, **_options)
    @url = url
    @width = width
    @height = height
    @color =  color.presence || '395c96'
  end

  def render?
    @url.present?
  end

  def src
    GoogleMapUrl.new(@url).embeddable.with_background(@color)
  end

  def attributes
    {
      src: src,
      width: @width,
      height: @height
    }
  end
end
