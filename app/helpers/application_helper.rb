# frozen_string_literal: true

module ApplicationHelper
  def attribute_name(attribute, model:)
    model.human_attribute_name(attribute)
  end

  def model_name(model)
    model.model_name.human
  end
end
