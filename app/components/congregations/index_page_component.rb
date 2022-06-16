# frozen_string_literal: true

module Congregations
  class IndexPageComponent < PageComponent
    attr_reader :congregations

    def initialize(congregations)
      @congregations = congregations
      setup_breadcrumb
    end

    def new_link
      link_to(t('app.links.new'), new_public_talks_congregation_path)
    end

    def edit_link(congregation)
      link_to(t('app.links.edit'), edit_public_talks_congregation_path(congregation))
    end

    def destroy_link(congregation)
      link_to(
        t('app.links.delete'), public_talks_congregation_path(congregation),
        data: { method: :delete, confirm: delete_confirmation(congregation) }
      )
    end

    private

    def delete_confirmation(congregation)
      t('app.messages.confirm_delete_x', record: congregation.name)
    end

    def setup_breadcrumb
      breadcrumb.add_item(t('app.links.congregations'))
    end
  end
end
