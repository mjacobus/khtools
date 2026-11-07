# frozen_string_literal: true

module ApplicationHelper
  def attribute_name(attribute, model:)
    model.human_attribute_name(attribute)
  end

  def model_name(model)
    model.model_name.human
  end

  # A native date input follows the browser language (mm/dd/yyyy in an English Chrome), so
  # "10/06" was taken as October 6th. A text field always reads day/month/year.
  def br_date_options(date)
    { value: date&.strftime('%d/%m/%Y'), placeholder: 'dd/mm/aaaa', inputmode: 'numeric',
      pattern: '\\d{2}/\\d{2}/\\d{4}', title: 'dd/mm/aaaa' }
  end
end
