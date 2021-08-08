# frozen_string_literal: true

module Congregation
  module Publishers
    class ListItemComponent < ApplicationComponent
      has :publisher

      def attribute(name)
        "Congregation::Publishers::Publisher#{name.to_s.classify}Component".constantize.new(publisher, attribute_name: name)
      end

      def edit_link
        link_to(t('app.links.edit'), urls.edit_publisher_path(publisher))
      end

      def destroy_link
        link_to(
          t('app.links.delete'), urls.to(publisher),
          data: { method: :delete, confirm: delete_confirmation(publisher) }
        )
      end

      def show_link
        link_to(t('app.links.view'), urls.to(publisher))
      end

      private

      def delete_confirmation(publisher)
        t('app.messages.confirm_delete_x', record: publisher.name)
      end
    end
  end
end
