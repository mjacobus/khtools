# frozen_string_literal: true

class PageComponent < ApplicationComponent
  def breadcrumb
    @breadcrumb ||= BreadcrumbComponent.new.tap do |b|
      b.add_item('Home', urls.root_path)
    end
  end

  def icon(name, &block)
    icon = tag.i('', class: "bi bi-#{name}")

    unless block
      return icon
    end

    icon + '&nbsp;'.html_safe + yield
  end
end
