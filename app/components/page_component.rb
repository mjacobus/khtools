# frozen_string_literal: true

class PageComponent < ApplicationComponent
  def initialize(*args)
    super

    send(:setup_breadcrumb) if respond_to?(:setup_breadcrumb, true)
  end

  def breadcrumb
    @breadcrumb ||= BreadcrumbComponent.new.tap do |b|
      b.add_item(t('app.links.home'), urls.root_path, false)
    end
  end

  def input_wrapper(&block)
    tag.div(class: 'form-wrapper my-3', &block)
  end
end
