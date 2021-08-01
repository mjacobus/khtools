# frozen_string_literal: true

class Territories::SearchFormComponent < ApplicationComponent
  def initialize(type:, params:)
    @type = type
    @search = SearchParams.new(params)
  end

  def action
    url_for
  end

  def reset_url
    url_for(publiser_id: nil, name: nil, phone_provider_id: nil)
  end

  def type
    ActiveSupport::StringInquirer.new(@type.to_s)
  end

  def name_input(form)
    form.text_field(:name, input_options.merge(value: @search[:name]))
  end

  def phone_provider_input(form)
    phone_providers = Db::PhoneProvider.pluck(:name, :id)
    select_input(form, phone_providers, :phone_provider_id)
  end

  def publisher_input(form)
    publishers = Db::Publisher.pluck(:name, :id)
    no_one = [[t('app.messages.unassigned_territory'), 'none']]
    select_input(form, (no_one + publishers), :publisher_id)
  end

  def name_label
    attribute_name(Db::Territory, :name)
  end

  def publisher_label
    attribute_name(Db::Territory, :assignee)
  end

  def phone_provider_label
    attribute_name(Db::Territory, :phone_provider)
  end

  def open_attribute
    @search.any?(:name, :publisher_id, :phone_provider_id) ? 'open' : ''
  end

  private

  def select_input(form, options, key)
    form.select(key, options, { selected: @search[key], include_blank: true }, input_options)
  end

  def input_options
    { class: 'form-control' }
  end
end
