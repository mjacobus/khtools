# frozen_string_literal: true

module CrudController
  extend ActiveSupport::Concern

  def index
    records = paginate(scope)
    render index_component(records)
  end

  def show
    render show_component(record)
  end

  def new
    @record = scope.new
    render form_component(record)
  end

  def create
    @record = scope.new
    save_record
  end

  def edit
    render form_component(record)
  end

  def update
    save_record
  end

  def destroy
    record.destroy
    redirect_to(action: :index)
  end

  private

  def index_component(records)
    component_class(:index).new(pluralized_key => records)
  end

  def show_component(record)
    component_class(:show).new(key => record)
  end

  def form_component(record)
    component_class(:form).new(key => record)
  end

  def record
    @record ||= scope.find(params[:id])
  end

  def save_record
    record.attributes = attributes

    if record.save
      redirect_to action: :index
      return
    end

    render form_component(record), status: :unprocessable_entity
  end

  def attributes
    params.require(key).permit(*allowed_attributes)
  end

  def key
    raise 'Define key :key_name'
  end

  def pluralized_key
    raise 'Define key :key_name [:pluralized_key]'
  end

  def allowed_attributes
    raise 'Define permit :attr1, :attr2...'
  end

  def scope
    raise 'Define scope { Model.all }'
  end

  def component_class(_name)
    raise "Define component_class_template 'SomeNamespace::%{type}PageComponent'"
  end

  module ClassMethods
    def key(key, pluralized = nil)
      define_method :key do
        key
      end
      private :key

      define_method :pluralized_key do
        pluralized || key.to_s.pluralize.to_sym
      end
      private :pluralized_key
    end

    def permit(*args)
      define_method :allowed_attributes do
        args
      end
      private :allowed_attributes
    end

    # rubocop:disable Performance/RedundantBlockCall:
    def scope(&block)
      define_method :scope do
        block.call
      end
      private :scope
    end
    # rubocop:enable Performance/RedundantBlockCall:

    def component_class_template(value)
      define_method :component_class do |type|
        value.sub('%{type}', type.to_s.classify).constantize
      end
      private :component_class
    end
  end
end
