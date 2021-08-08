# frozen_string_literal: true

class Territories::SearchFormComponent < ApplicationComponent
  def initialize(prototype:, params:)
    @prototype = prototype
    @search = SearchParams.new(params)
  end

  def render?
    @prototype.present?
  end

  def action
    url_for
  end

  def reset_url
    url_for(publiser_id: nil, name: nil, phone_provider_id: nil)
  end

  def type
    ActiveSupport::StringInquirer.new(@prototype.type_key.to_s)
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

  def area_input(form)
    areas = Db::TerritoryArea.pluck(:name, :id)
    select_input(form, areas, :area_id)
  end

  def preaching_method_input(form)
    values = Db::PreachingMethod.pluck(:name, :id)
    select_input(form, values, :preaching_method_id)
  end

  def name_label
    attribute_name(Db::Territory, :name)
  end

  def publisher_label
    attribute_name(Db::Territory, :assignee)
  end

  def area_label
    attribute_name(Db::Territory, :area)
  end

  def preaching_method_label
    attribute_name(Db::Territory, :preaching_method)
  end

  def phone_provider_label
    attribute_name(Db::Territory, :phone_provider)
  end

  def open_attribute
    @search.any?(:name, :publisher_id, :phone_provider_id, :area_id) ? 'open' : ''
  end

  def editable_attribute?(attribute_name)
    @prototype.editable_attributes.include?(attribute_name)
  end

  def include_preaching_method?
    editable_attribute?(:primary_preaching_method_id) ||
      editable_attribute?(:secondary_preaching_method_id) ||
      editable_attribute?(:tertiary_preaching_method_id)
  end

  private

  def select_input(form, options, key)
    form.select(key, options, { selected: @search[key], include_blank: true }, input_options)
  end

  def input_options
    { class: 'form-control' }
  end
end
