# frozen_string_literal: true

module Admin
  class Authorization
    def initialize(request)
      @request = request
    end

    def authorized?(user)
      unless user
        return false
      end

      if user.master?
        return true
      end

      authorized_controller_action(user)
    end

    private

    def authorized_controller_action(user)
      allowed_items = [
        "#{@request.params[:controller]}|#{@request.params[:action]}",
        "#{@request.params[:controller]}|*"
      ]
      (user.permissions['controllers'] & allowed_items).any?
    end
  end
end
