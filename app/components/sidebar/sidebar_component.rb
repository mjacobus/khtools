# frozen_string_literal: true

class Sidebar::SidebarComponent < ApplicationComponent
  renders_one :main_container

  def render?
    current_user
  end

  def menu_entries
    [
      home_link,
      meeting_attendance,
      field_service_section,
      admin_section,
      logout
    ].compact
  end

  private

  def home_link
    entry('Home', root_path)
  end

  def meeting_attendance
    entry(t('app.links.meeting_attendance'), meeting_attendance_meetings_url)
  end

  def field_service_section
    entry(t('app.links.field_service'), '#').tap do |section|
      section.append_child(field_service_campaigns)
    end
  end

  def admin_dashboard
    if current_user.master?
      entry('Dashboard', admin_dashboard_url)
    end
  end

  def users
    entry(t('app.links.users'), users_path)
  end

  def field_service_campaigns
    entry(t('app.links.preaching_campaigns'), field_service_campaigns_url)
  end

  def admin_section
    if current_user.master?
      entry('Admin', '#').tap do |section|
        section.append_child(admin_dashboard)
        section.append_child(users)
      end
    end
  end

  def logout
    entry(t('app.links.logout'), '/logout')
  end

  def entry(*args)
    Sidebar::MenuEntry.new(*args)
  end
end
