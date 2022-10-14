# frozen_string_literal: true

module Congregation
  module Publishers
    class FormPageComponent < PageComponent
      has :publisher

      def target_url
        if publisher.id
          return urls.to(publisher)
        end

        urls.publishers_path
      end

      def genders
        [%w[Masculino m], %w[Feminino f]]
      end

      def groups
        current_account.field_service_groups.order(:name).pluck(:name, :id)
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.publishers'), urls.publishers_path)

        if publisher.id
          breadcrumb.add_item(publisher.name, urls.to(publisher))
          breadcrumb.add_item(t('app.links.edit'))
          return
        end

        breadcrumb.add_item(t('app.links.new'))
      end
    end
  end
end
