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
      field_service_campaigns,
      admin_dashboard,
      users,
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

  def admin_dashboard
    if current_user.master?
      entry('Admin', admin_dashboard_url)
    end
  end

  def users
    entry(t('app.links.users'), users_path)
  end

  def field_service_campaigns
    entry(t('app.links.preaching_campaigns'), field_service_campaigns_url)
  end

  def logout
    entry(t('app.links.logout'), '/logout')
  end

  def entry(*args)
    Sidebar::MenuEntry.new(*args)
  end
end
