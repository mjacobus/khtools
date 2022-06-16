# frozen_string_literal: true

module Territories
  module Contacts
    class FormPageComponent < PageComponent
      has :contact
      has :territory

      def page_title
        model_name(contact)
      end

      def target_url
        return territories_commercial_territory_contact_path(territory, contact) if contact.id

        territories_commercial_territory_contacts_path(territory)
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(
          t('app.links.commercial_territories'),
          urls.territories_commercial_territories_path
        )

        breadcrumb.add_item(territory.name, urls.to(territory))

        breadcrumb.add_item(
          t('app.links.contacts'),
          urls.territories_commercial_territory_contacts_path(territory)
        )

        action = contact.id ? 'edit' : 'new'
        breadcrumb.add_item(t("app.links.#{action}"))
      end
    end
  end
end
