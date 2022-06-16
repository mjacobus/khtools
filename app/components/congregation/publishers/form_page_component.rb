# frozen_string_literal: true

module Congregation
  module Publishers
    class FormPageComponent < PageComponent
      has :publisher

      def target_url
        return urls.to(publisher) if publisher.id

        urls.publishers_path
      end

      def genders
        [%w[Masculino m], %w[Feminino f]]
      end

      def groups
        Db::FieldServiceGroup.order(:name).pluck(:name, :id)
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
