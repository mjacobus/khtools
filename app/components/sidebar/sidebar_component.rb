# frozen_string_literal: true

# Icons: https://icons.getbootstrap.com/

# rubocop:disable Metrics/ClassLength
class Sidebar::SidebarComponent < ApplicationComponent
  renders_one :main_container

  def render?
    current_user
  end

  def menu_entries
    [
      home_link,
      meeting_attendance,
      territories_section,
      field_service_section,
      admin_section,
      logout
    ].compact
  end

  private

  def home_link
    entry('Home', root_path, icon: 'house-door')
  end

  def meeting_attendance
    entry(t('app.links.meeting_attendance'), meeting_attendance_meetings_url,
          icon: 'sort-numeric-up')
  end

  def territories_section
    entry(t('app.links.territories'), '#', icon: 'map').tap do |section|
      section.append_child(apartment_building_territories)
      section.append_child(phone_list_territories)
      section.append_child(regular_territories)
      section.append_child(commercial_territories)
    end
  end

  def field_service_section
    entry(t('app.links.field_service'), '#', icon: 'book').tap do |section|
      section.append_child(territory_areas)
      section.append_child(preaching_methods)
      section.append_child(field_service_campaigns)
      section.append_child(intercom_types)
      section.append_child(letter_box_types)
      section.append_child(phone_providers)
      section.append_child(field_service_groups)
      section.append_child(publishers)
    end
  end

  def admin_preaching_campaigns(*_args)
    entry(Db::PreachingCampaign.model_name.human, admin_db_preaching_campaigns_path,
          icon: 'reception-4')
  end

  def preaching_methods
    entry(Db::PreachingMethod.model_name.human, admin_db_preaching_methods_path, icon: 'whatsapp')
  end

  def field_service_groups
    entry(Db::FieldServiceGroup.model_name.human, admin_db_field_service_groups_path,
          icon: 'people')
  end

  def phone_providers
    entry(Db::PhoneProvider.model_name.human, admin_db_phone_providers_path, icon: 'phone')
  end

  def intercom_types
    entry(Db::IntercomType.model_name.human, admin_db_intercom_types_path, icon: 'soundwave')
  end

  def letter_box_types
    entry(Db::LetterBoxType.model_name.human, admin_db_letter_box_types_path, icon: 'mailbox2')
  end

  def territory_areas
    entry(Db::TerritoryArea.model_name.human, admin_db_territory_areas_path, icon: 'pin-map')
  end

  def regular_territories
    entry(Db::RegularTerritory.model_name.human, territories_regular_territories_path, icon: 'map')
  end

  def commercial_territories
    entry(
      Db::CommercialTerritory.model_name.human,
      territories_commercial_territories_path,
      icon: 'cart4'
    )
  end

  def phone_list_territories
    entry(Db::PhoneListTerritory.model_name.human, admin_db_phone_list_territories_path,
          icon: 'phone')
  end

  def apartment_building_territories
    entry(Db::ApartmentBuildingTerritory.model_name.human,
          admin_db_apartment_building_territories_path, icon: 'building')
  end

  def admin_dashboard
    if current_user.master?
      entry('Dashboard', admin_dashboard_url, icon: 'file-bar-graph')
    end
  end

  def users
    entry(User.model_name.human, users_path, icon: 'people')
  end

  def field_service_campaigns
    entry(Db::PreachingCampaign.model_name.human, field_service_campaigns_url, icon: 'reception-4')
  end

  def publishers
    entry(Db::Publisher.model_name.human, admin_db_publishers_path, icon: 'person-circle')
  end

  def admin_section
    if current_user.master?
      entry('Admin', '#', icon: 'pencil').tap do |section|
        section.append_child(admin_dashboard)
        section.append_child(users)
        section.append_child(admin_preaching_campaigns)
      end
    end
  end

  def logout
    entry(t('app.links.logout'), '/logout', icon: 'door-open')
  end

  def entry(text, url, **args)
    Sidebar::MenuEntry.new(text, url, **args)
  end
end
# rubocop:enable Metrics/ClassLength
