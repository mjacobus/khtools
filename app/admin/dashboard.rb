# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: -1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel t('views.dashboard.overview') do
          div do
            span t('views.dashboard.number_of_publishers')
            span Db::Publisher.count
          end
        end
      end

      column do
        panel t('views.dashboard.territories') do
          models = [
            Db::RegularTerritory,
            Db::PhoneListTerritory,
            Db::ApartmentBuildingTerritory
          ]

          models.each do |model|
            div do
              span model.model_name.human
              span ':'
              span do
                link_to model.count,
                        send("admin_#{model.to_s.underscore.pluralize.sub('/', '_')}_path")
              end
            end
          end
        end
      end
    end

    columns do
      Db::FieldServiceGroup.active.order(:name).each do |group|
        column do
          panel group.name do
            group.publishers.each do |publisher|
              div link_to(publisher.name, admin_db_publisher_path(publisher))
            end
          end
        end
      end
    end
  end
end
