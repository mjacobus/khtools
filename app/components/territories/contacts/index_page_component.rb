# frozen_string_literal: true

module Territories
  module Contacts
    class IndexPageComponent < PageComponent
      attr_reader :territory, :contacts

      def initialize(territory:)
        @territory = territory
        @contacts = territory.contacts
        setup_breadcrumb
      end

      def title
        model_name(Db::Contact).pluralize
      end

      def edit_path(contact)
        edit_territories_commercial_territory_contact_path(territory, contact)
      end

      def contact_path(contact)
        territories_commercial_territory_contact_path(territory, contact)
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(
          t('app.links.commercial_territories'),
          urls.territories_commercial_territories_path
        )

        breadcrumb.add_item(territory.name, urls.to(@territory))

        breadcrumb.add_item(t('app.links.contacts'))
      end
    end
  end
end
