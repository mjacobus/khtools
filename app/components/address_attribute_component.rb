# frozen_string_literal: true

class AddressAttributeComponent < AttributeWrapperComponent
  def initialize(value)
    @value = value
    with_label('address')
    without_label
  end

  def icon_name
    'map'
  end
end
