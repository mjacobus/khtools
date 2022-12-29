# frozen_string_literal: true

class Territories::SearchFormComponent < ApplicationComponent
  def initialize(prototype:, params:)
    @prototype = prototype
    @search = SearchParams.new(params)
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
    publishers = current_account.publishers.pluck(:name, :id)
    no_one = [[t('app.messages.unassigned_territory'), 'none']]
    select_input(form, (no_one + publishers), :publisher_id)
  end

  def field_service_group_label
    attribute_name(Db::Territory, :field_service_group)
  end

  def field_service_group_input(form)
    groups = current_account.field_service_groups.order(:name).pluck(:name, :id)
    select_input(form, groups, :field_service_group_id)
  end

  def area_input(form)
    areas = Db::TerritoryArea.pluck(:name, :id)
    select_input(form, areas, :area_id)
  end

  def preaching_method_input(form)
    values = Db::PreachingMethod.pluck(:name, :id)
    select_input(form, values, :preaching_method_id)
  end

  def territory_label
    attribute_name(Db::Territory, :territory)
  end

  def territory_input(form)
    values = Db::RegularTerritory.pluck(:name, :id)
    select_input(form, values, :territory_id)
  end

  def pending_verification_label
    attribute_name(Db::Territory, :pending_verification)
  end

  def pending_verification_input(form)
    values = [[I18n.t('true'), true], [I18n.t('false'), false]]
    select_input(form, values, :pending_verification)
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
    filters = %i[
      name
      publisher_id
      field_service_group_id
      phone_provider_id
      preaching_method_id
      area_id
      territory_id
      pending_verification
    ]
    @search.any?(filters) ? 'open' : ''
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
