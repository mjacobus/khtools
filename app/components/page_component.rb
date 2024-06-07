# frozen_string_literal: true

class PageComponent < ApplicationComponent
  def initialize(*args)
    super

    if respond_to?(:setup_breadcrumb, true)
      send(:setup_breadcrumb)
    end
  end

  def breadcrumb
    @breadcrumb ||= BreadcrumbComponent.new.tap do |b|
      b.add_item(t('app.links.home'), urls.root_path, false)
    end
  end

  def input_wrapper(&)
    tag.div(class: 'form-wrapper my-3', &)
  end
end
