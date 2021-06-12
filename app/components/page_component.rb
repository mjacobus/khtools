# frozen_string_literal: true

class PageComponent < ApplicationComponent
  def breadcrumb
    @breadcrumb ||= BreadcrumbComponent.new.tap do |b|
      b.add_item('Home', urls.root_path)
    end
  end
end
