# frozen_string_literal: true
# frozen_string_literal: tru

class Territories::SearchFormComponent < ApplicationComponent
  def initialize(type:, params:)
    @type = type
    @search = SearchParams.new(params)
    @params = params
  end

  def action
    url_for
  end

  def type
    ActiveSupport::StringInquirer.new(@type.to_s)
  end

  def phone_providers_select(form)
    phone_providers = Db::PhoneProvider.pluck(:name, :id)
    select_input(form, phone_providers, :phone_provider_id)
  end

  def publishers_select(form)
    publishers = Db::Publisher.pluck(:name, :id)
    select_input(form, publishers, :publisher_id)
  end

  def publishers_label
    attribute_name(Db::Territory, :assignee)
  end

  def phone_providers_label
    attribute_name(Db::Territory, :phone_provider)
  end

  def open_attribute
    @search.any?(:publisher_id, :phone_provider_id) ? 'open' : ''
  end

  private

  def select_input(form, options, key)
    form.select(key, options, { selected: params[key], include_blank: true }, input_options)
  end

  def input_options
    { class: 'form-control' }
  end
end
