# frozen_string_literal: true

class Sidebar::SidebarComponent < ApplicationComponent
  renders_one :main_container

  def render?
    current_user
  end
end
