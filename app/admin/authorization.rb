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

      false
    end
  end
end
