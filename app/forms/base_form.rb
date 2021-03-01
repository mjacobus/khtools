# frozen_string_literal: true

class BaseForm
  include ActiveModel::Model
  delegate :persisted?, :to_param, to: :@record

  def initialize(record)
    @record = record
  end

  def save
    if valid?
      @record.save
    end
  end

  def destroy
    @record.destroy
  end

  def model_name
    @model_name ||= ActiveModel::Name.new(@record.class, nil, singular_route_key).tap do |name|
      name.param_key = param_key
      name.i18n_key = @record.model_name.i18n_key
    end
  end

  private

  def singular_route_key
    @record.class.to_s.sub('Db::', '')
  end

  def param_key
    @record.class.to_s.split('::').last.underscore
  end
end
