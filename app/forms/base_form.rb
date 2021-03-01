# frozen_string_literal: true

class BaseForm
  include ActiveModel::Model
  delegate :persisted?, :to_param, to: :@record

  def initialize(record)
    @record = record
  end

  def save
    if valid?
      @record.save!
    end
  end

  def destroy
    @record.destroy
  end

  # TODO: Fix the following issue
  #
  # This hack is not working very well with simple_form i18n file.
  # AR attributes i18n is also not working well.
  def model_name
    @model_name ||= ActiveModel::Name.new(model_class, nil, singular_route_key).tap do |name|
      name.param_key = param_key
      name.i18n_key = i18n_key
    end
  end

  private

  def singular_route_key
    @record.class.to_s.sub('Db::', '')
  end

  def param_key
    @record.class.to_s.split('::').last.underscore
  end

  def model_class
    @record.class
  end

  def i18n_key
    @record.model_name.i18n_key
  end
end
